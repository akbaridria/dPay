import { network, run } from 'hardhat'
import * as fs from 'fs'
import * as path from 'path'
import chains from '../datas/chains.json'

async function main() {
  const chain = chains.filter((item) => item.chainName === network.name)[0];
  console.log('verifying dpay contract..');

  try {
    // verify contracts on etherscan
    await run(`verify:verify`, {
      address: chain.contractAddress,
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

    console.log("verify success!");
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
