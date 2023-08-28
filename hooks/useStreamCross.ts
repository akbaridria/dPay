import { ethers } from 'ethers'
import { MetaMaskInpageProvider } from "@metamask/providers";
import { DPayConnector__factory } from '../protocol-contract/typechain-types';
import { FormStream } from '../interfaces/globalInterfaces'
import { delay } from '../utils/helper'

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}

export const depositEthCross = async (contractAddress: string, form: FormStream, gasFee: bigint) : Promise<string> => {
  if(window.ethereum) {
    const provider = new ethers.BrowserProvider((window as any).ethereum)
    const dPay = DPayConnector__factory.connect(contractAddress, await provider.getSigner())
    if(form.flowAmount && form.totalAmount) {
      const tx = await dPay.deposit(
        form.totalAmount*1e6,
        form.flowAmount*1e6,
        form.flowRate,
        form.recipient,
        {
          value: gasFee,
          gasLimit: 300000
        }
      )
      await delay(2000)
      return tx.hash
    }
   
    return ''
  }
  return ''
}

export const depositAgainETHCross = async (contractAddress: string, id: number, amount:number, gasFee: bigint) : Promise<string> => {
  if(window.ethereum) {
    const provider = new ethers.BrowserProvider((window as any).ethereum)
    const dPay = DPayConnector__factory.connect(contractAddress, await provider.getSigner())
    const tx = await dPay.depositAgain(
      id,
      amount*1e6,
      {
        value: gasFee,
        gasLimit: 300000
      }
    )
    await delay(2000)
    return tx.hash
  }
  return ''
}