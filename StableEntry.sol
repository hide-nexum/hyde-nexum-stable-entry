// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IStableRouter {
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient
    ) external returns (uint256 amountOut);
}

contract StableEntry {
    address public immutable router;

    mapping(address => bool) public supportedInputTokens;
    mapping(address => bool) public supportedStablecoins;

    bool private locked;

    event StableEntryExecuted(
        address indexed user,
        address indexed tokenIn,
        address indexed stablecoin,
        uint256 amountIn,
        uint256 amountOut
    );

    error UnsupportedToken();
    error InvalidAmount();
    error SlippageExceeded();
    error Reentrancy();

    modifier nonReentrant() {
        if (locked) revert Reentrancy();
        locked = true;
        _;
        locked = false;
    }

    constructor(
        address router_,
        address[] memory inputTokens_,
        address[] memory stablecoins_
    ) {
        router = router_;

        for (uint256 i = 0; i < inputTokens_.length; i++) {
            supportedInputTokens[inputTokens_[i]] = true;
        }

        for (uint256 i = 0; i < stablecoins_.length; i++) {
            supportedStablecoins[stablecoins_[i]] = true;
        }
    }

    /// @notice Converts a supported asset into a supported stablecoin.
    /// @dev The transaction reverts if minAmountOut cannot be satisfied.
    function stableEntry(
        address tokenIn,
        address stablecoin,
        uint256 amountIn,
        uint256 minAmountOut
    ) external nonReentrant returns (uint256 amountOut) {
        if (!supportedInputTokens[tokenIn]) revert UnsupportedToken();
        if (!supportedStablecoins[stablecoin]) revert UnsupportedToken();
        if (amountIn == 0 || minAmountOut == 0) revert InvalidAmount();

        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "TRANSFER_FAILED"
        );

        // Exact approval for this operation.
        require(
            IERC20(tokenIn).approve(router, amountIn),
            "APPROVE_FAILED"
        );

        amountOut = IStableRouter(router).swap(
            tokenIn,
            stablecoin,
            amountIn,
            minAmountOut,
            msg.sender
        );

        // Remove any remaining allowance after execution.
        IERC20(tokenIn).approve(router, 0);

        if (amountOut < minAmountOut) revert SlippageExceeded();

        emit StableEntryExecuted(
            msg.sender,
            tokenIn,
            stablecoin,
            amountIn,
            amountOut
        );
    }
}
