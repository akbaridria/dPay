import { ethers } from 'ethers'
import { IERC20__factory } from '../protocol-contract/typechain-types/factories/@openzeppelin/contracts/token/ERC20';
import { MetaMaskInpageProvider } from "@metamask/providers";

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}
export const getAllowance = async (spenderAddress: string, userWallet: string, contractAddress: string) : Promise<BigInt> => {
  if(window.ethereum) {
    const provider = new ethers.BrowserProvider((window as any).ethereum)
    const erc20 = IERC20__factory.connect(contractAddress, provider)
    const allowance = await erc20.allowance(userWallet, spenderAddress);
    return allowance
  }
  return 0n
}