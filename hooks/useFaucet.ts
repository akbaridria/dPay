import { ethers } from 'ethers'
import { MetaMaskInpageProvider } from "@metamask/providers";
import { IAaveFaucet__factory } from '../protocol-contract/typechain-types';
import { delay } from '../utils/helper'
import datas from '../protocol-contract/datas/chains.json'

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}

export const getFaucet = async (userWallet: string) => {
  if(window.ethereum) {
    const chain = datas.filter((item) => item.chainId === 5)[0]
    const provider =  new ethers.BrowserProvider((window as any).ethereum)
    const faucet = IAaveFaucet__factory.connect(chain.aaveFaucet as string, await provider.getSigner())
    const tx = await faucet.mint(chain.usdc as string, userWallet, 200*1e6)
    await delay(2000)
    return tx.hash
  }
  return ''
}