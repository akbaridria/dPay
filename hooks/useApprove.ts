import { ethers } from 'ethers'
import { IERC20__factory } from '../protocol-contract/typechain-types/factories/@openzeppelin/contracts/token/ERC20';
import { MetaMaskInpageProvider } from "@metamask/providers";

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}
export const approveToken = async (spenderAddress: string, amount: number | bigint, contractAddress: string) : Promise<boolean> => {
  if(window.ethereum) {
    const provider = new ethers.BrowserProvider((window as any).ethereum)
    const erc20 = IERC20__factory.connect(contractAddress, await provider.getSigner())
    const allowance = await erc20.approve(spenderAddress, amount)
    await allowance.wait()
    return true
  }
  return false
}