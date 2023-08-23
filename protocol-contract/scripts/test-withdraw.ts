import { ethers, network } from 'hardhat'
import chains from '../datas/chains.json'

const {
  AxelarQueryAPI,
  Environment,
  EvmChain,
  GasToken,
} = require("@axelar-network/axelarjs-sdk");

require("dotenv").config();

async function main() {
  const chain = chains.filter((item) => item.chainName === network.name)[0];
  const dpayconnector = await ethers.getContractFactory('DPayConnector');
  const _dpayconnector = dpayconnector.attach(chain.contractAddress);
  const api = new AxelarQueryAPI({ environment: Environment.TESTNET });
  const id = 1;
  const gasFee = await api.estimateGasFee(
    chain.fee,
    "ethereum-2",
    chain.symbol,
    1000000,
    1.5
  );
  const feeBack = await api.estimateGasFee(
    "ethereum-2",
    chain.fee,
    chain.symbol,
    1000000,
    1.5
  )


  // execute contract
  const tx = await _dpayconnector.withdraw( id, {
    value: ethers.BigNumber.from(gasFee).add(ethers.BigNumber.from(feeBack))
  })
  await tx.wait()
  console.log('done transaction')
 
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
