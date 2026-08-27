const SUPPORTED_STABLES = {
  USDC: {
    symbol: "USDC",
    placeholderAddress: "STABLECOIN_ADDRESS_USDC"
  },
  USDT: {
    symbol: "USDT",
    placeholderAddress: "STABLECOIN_ADDRESS_USDT"
  },
  DAI: {
    symbol: "DAI",
    placeholderAddress: "STABLECOIN_ADDRESS_DAI"
  }
};

/**
 * Demo recommendation engine.
 *
 * In production, this function can receive a structured response
 * from Nexum GPT, but the final output must still be validated
 * against the application's local whitelist.
 */
export function buildStablePlan(userIntent) {
  const text = userIntent.toLowerCase();

  let stablecoin = "USDC";

  if (text.includes("decentralized") || text.includes("decentral")) {
    stablecoin = "DAI";
  }

  if (text.includes("liquidity") || text.includes("ликвид")) {
    stablecoin = "USDT";
  }

  const amountMatch = userIntent.match(/(\d+(?:[.,]\d+)?)/);
  const targetAmount = amountMatch
    ? Number(amountMatch[1].replace(",", "."))
    : null;

  return {
    stablecoin: SUPPORTED_STABLES[stablecoin],
    targetAmountUSD: targetAmount,
    network: "TESTNET_NETWORK_PLACEHOLDER",
    maxSlippagePercent: 0.5,
    disclaimer:
      "Demo recommendation. Review all transaction details before confirming."
  };
}
