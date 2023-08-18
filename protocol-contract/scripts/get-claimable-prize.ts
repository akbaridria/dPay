import { ethers, network, run } from 'hardhat'
import chains from '../datas/chains.json'
import { DPayReward__factory } from '../typechain-types';

async function main() {
  const chain = chains.filter((item) => item.chainName === network.name)[0];
  const rewardContract:DPayReward__factory = await ethers.getContractFactory('DPayReward')
  const _reward = (await rewardContract).attach('0x857db996f452571e4B0c630cF9d6848A20a9d264')
  const d = await _reward.totalDeposit()
  console.log(d)
  const e = await _reward.getClaimablePrize()
  console.log(e)
 
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
