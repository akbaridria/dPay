import chains from '../datas/chains.json'

import { AxelarQueryAPI, Environment } from "@axelar-network/axelarjs-sdk";

export const calculate = async (chainId: number) => {
  const chain = chains.filter((item) => item.chainId === chainId)[0];
  const api = new AxelarQueryAPI({ environment: Environment.TESTNET });
  const gasFee = await api.estimateGasFee(
    chain.fee,
    "ethereum-2",
    chain.symbol,
    1300000,
    2
  );
  return gasFee
}
