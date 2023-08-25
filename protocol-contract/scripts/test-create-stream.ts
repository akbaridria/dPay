import { ethers, network } from 'hardhat'
import chains from '../datas/chains.json'
import { DPayConnector, DPayConnector__factory } from '../typechain-types';
import { IERC20__factory } from '../typechain-types/factories/@openzeppelin/contracts/token/ERC20';
import { IERC20 } from '../typechain-types/@openzeppelin/contracts/token/ERC20';

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
  const provider = new ethers.providers.JsonRpcProvider(chain.rpc)
  const signer = new ethers.Wallet(process.env.PRIV_KEY, provider)
  const erc20 = new ethers.Contract(
    chain.axlToken,
    IERC20__factory.abi,
    signer
  )
  const amount = 100_000_000;

  const api = new AxelarQueryAPI({ environment: Environment.TESTNET });
  const gasFee = await api.estimateGasFee(
    chain.fee,
    "ethereum-2",
    chain.symbol,
    1300000,
    2
  );
  // approve ausdc
  const txApprove = await erc20.approve(chain.contractAddress, amount)
  await txApprove.wait();
  console.log('done approving usdc');
  // execute contract
  const tx = await _dpayconnector.deposit(amount, amount, 'months', '0x5afF62d808b0eC5286A8220cCd3135aC523451a0', {
    value: ethers.BigNumber.from(gasFee)
  })
  await tx.wait()
  console.log('done transaction')
 
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
