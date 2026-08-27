import { ethers } from "ethers";

const CONTRACT_ADDRESS = "STABLE_ENTRY_CONTRACT_ADDRESS";
const RPC_URL = "RPC_ENDPOINT_PLACEHOLDER";

const ABI = [
  "function stableEntry(address tokenIn, address stablecoin, uint256 amountIn, uint256 minAmountOut) returns (uint256)"
];

export async function executeStableEntry({
  walletProvider,
  tokenIn,
  stablecoin,
  amountIn,
  minAmountOut
}) {
  if (!walletProvider) {
    throw new Error("Wallet is not connected");
  }

  const provider = new ethers.BrowserProvider(walletProvider);
  const signer = await provider.getSigner();

  const contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    ABI,
    signer
  );

  // The wallet displays the transaction for user review.
  const transaction = await contract.stableEntry(
    tokenIn,
    stablecoin,
    amountIn,
    minAmountOut
  );

  return transaction;
}

export function getPlaceholderConfig() {
  return {
    rpcUrl: RPC_URL,
    contract: CONTRACT_ADDRESS,
    network: "TESTNET_NETWORK_PLACEHOLDER"
  };
}
