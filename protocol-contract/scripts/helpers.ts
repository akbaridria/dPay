import { ethers } from 'hardhat'
import { IERC20__factory } from '../typechain-types/factories/@openzeppelin/contracts/token/ERC20';
import chains from '../datas/chains.json'
import { MetaMaskInpageProvider } from "@metamask/providers";

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}
export const getBalance = async (name: string) => {
  if(window.ethereum) {
    const chain = chains.filter((item) => item.chainName === name)[0];
    const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signerPol = provider.getSigner();

    const erc20 = new ethers.Contract(
      chain.axlToken,
      IERC20__factory.abi,
      signer
    )
  }
  
}