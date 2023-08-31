import { ethers } from 'ethers'
import { MetaMaskInpageProvider } from "@metamask/providers";
import { DPayReward__factory, DPay__factory } from '../protocol-contract/typechain-types';
import { delay } from '../utils/helper'
import { FormReward } from '../interfaces/globalInterfaces';

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}
// variables
const jsonRpc = 'https://eth.getblock.io/00f00ca4-fc2f-41d3-8454-2068adfb8aa7/goerli/'

export const getRewardDetail = async (userWallet: string, contractAddress: string) :Promise<FormReward> => {
  if(window.ethereum) {
    const provider = new ethers.JsonRpcProvider(jsonRpc)
    const dPay = DPay__factory.connect(contractAddress, provider)
    const d = await dPay.trackReward(userWallet)
    if(d.isEntity) {
      const dPayReward = DPayReward__factory.connect(d.rewardContract, provider);
      const e = await dPayReward.getClaimablePrize()
      return {
        isEntity: true,
        reward: (Math.round(+new Date()/1000) - Number(d.lastClaimTime)) + Number(e),
        lastClaimTime: Number(d.lastClaimTime)
      }
    }
  }
  return {
    isEntity: false,
    reward: 0,
    lastClaimTime: 0
  }
}

export const claimReward = async (contractAddress: string) :Promise<string> => {
  if(window.ethereum) {
    const provider = new ethers.BrowserProvider((window as any).ethereum)
    const dPay = DPay__factory.connect(contractAddress, await provider.getSigner())
    const tx = await dPay.claim()
    await delay(2000)
    return tx.hash
  }
  return ''
}