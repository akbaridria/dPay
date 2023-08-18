import { ethers, network, run } from 'hardhat'
import * as fs from 'fs'
import * as path from 'path'
import chains from '../datas/chains.json'
import { DPay, DPay__factory } from '../typechain-types';

async function main() {
  const chain = chains.filter((item) => item.chainName === network.name)[0];

  const dPayFactory:DPay__factory = await ethers.getContractFactory("DPay");
  const dPay:DPay = await dPayFactory.deploy(
    chain.gasReceiver,
    chain.gateway,
    chain.usdc,
    chain.aaveFaucet,
    chain.axlToken,
    chain.ipool,
    chain.aToken
  );
  
  console.log("depoloying dpay contract..")
  await dPay.deployed()
  chain.contractAddress = dPay.address
  console.log("dpay contract has been deployed : ", dPay.address)
  
  try {
    // verify contracts on etherscan
    await run(`verify:verify`, {
      address: dPay.address,
      constructorArguments: [
        chain.gasReceiver,
        chain.gateway,
        chain.usdc,
        chain.aaveFaucet,
        chain.axlToken,
        chain.ipool,
        chain.aToken
      ],
    });
  } catch (error) {
    console.log(error)
  }
  
  const filePath = path.join(__dirname, "../datas/chains.json");
  fs.writeFileSync(filePath, JSON.stringify(chains, null, 2));
  console.log("done");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
