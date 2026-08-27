// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20Mock {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract MockStableRouter {
    // Demo exchange rate:
    // 1 unit in = 1 unit out.
    // Replace with real routing logic in production.
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient
    ) external returns (uint256 amountOut) {
        amountOut = amountIn;

        require(amountOut >= minAmountOut, "SLIPPAGE");

        require(
            IERC20Mock(tokenIn).transferFrom(
                msg.sender,
                address(this),
                amountIn
            ),
            "INPUT_TRANSFER_FAILED"
        );

        require(
            IERC20Mock(tokenOut).transfer(recipient, amountOut),
            "OUTPUT_TRANSFER_FAILED"
        );
    }
}
