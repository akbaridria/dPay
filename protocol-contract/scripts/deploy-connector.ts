import { ethers, network, run } from 'hardhat'
import * as fs from 'fs'
import * as path from 'path'
import chains from '../datas/chains.json'
import { DPayConnector, DPayConnector__factory } from '../typechain-types';

async function main() {
  const chain = chains.filter((item) => item.chainName === network.name)[0];
  const ethereumChain = chains.filter((item) => item.chainName === 'ethereum')[0];

  const dPayConnector:DPayConnector__factory = await ethers.getContractFactory("DPayConnector");
  const dpayconnector:DPayConnector = await dPayConnector.deploy(
   chain.gateway,
   chain.gasReceiver,
   chain.axlToken,
   ethereumChain.contractAddress
  );
  
  console.log("depoloying dpay contract..")
  await dpayconnector.deployed()
  chain.contractAddress = dpayconnector.address
  console.log("dpay contract has been deployed : ", dpayconnector.address)
  
  try {
    // verify contracts on etherscan
    await run(`verify:verify`, {
      address: dpayconnector.address,
      constructorArguments: [
        chain.gateway,
        chain.gasReceiver,
        chain.axlToken,
        ethereumChain.contractAddress
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
