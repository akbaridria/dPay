import { ethers } from 'ethers'
import { MetaMaskInpageProvider } from "@metamask/providers";
import { DPay__factory } from '../protocol-contract/typechain-types';
import { FormStream } from '../interfaces/globalInterfaces'
import { delay } from '../utils/helper'

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}
import { ListSender } from '../interfaces/globalInterfaces'

// variables
const jsonRpc = 'https://eth.getblock.io/00f00ca4-fc2f-41d3-8454-2068adfb8aa7/goerli/'

export const depositEth = async (contractAddress: string, form: FormStream) : Promise<string> => {
  if(window.ethereum) {
    const provider = new ethers.BrowserProvider((window as any).ethereum)
    const dPay = DPay__factory.connect(contractAddress, await provider.getSigner())
    if(form.flowAmount && form.totalAmount) {
      const tx = await dPay.deposit(
        form.totalAmount*1e6,
        form.recipient,
        form.flowAmount*1e6,
        form.flowRate
      )
      await delay(2000)
      return tx.hash
    }
   
    return ''
  }
  return ''
}

export const depositAgainETH = async (contractAddress: string, id: number, amount: number) : Promise<string> => {
  if(window.ethereum) {
    const provider = new ethers.BrowserProvider((window as any).ethereum)
    const dPay = DPay__factory.connect(contractAddress, await provider.getSigner())
    const tx = await dPay.depositAgain(
      id, 
      amount*1e6
    )
    await delay(2000)
    return tx.hash
  }
  return ''
}

export const getListSenders = async (contractAddress: string, userWallet: string)  => {
  if(window.ethereum) {
    const provider = new ethers.JsonRpcProvider(jsonRpc)
    const dPay = DPay__factory.connect(contractAddress, provider)
    const eventsFilter = dPay.filters._Deposit(userWallet, undefined, undefined, undefined, undefined)
    const events = await dPay.queryFilter(eventsFilter, 9570762, 'latest')
    let listSenders:ListSender[] = []

    for(let event of events) {
      const e = await dPay.paymentStream(Number(event.args[2]))
      const temp :ListSender = {
        id: Number(event.args[2]),
        sender: e.sender,
        recipient: e.receiver,
        amount: Number(ethers.formatUnits(e.amount, 6)),
        remainingBalance: Number(ethers.formatUnits(e.remainingBalance, 6)),
        ratePerSecond: Number(ethers.formatUnits(e.ratePerSecond, 6)),
        starttime: Number(e.startTime),
        availabeAmount: ((Math.round(+new Date()/1000) - Number(e.startTime))*Number(ethers.formatUnits(e.ratePerSecond, 6))).toFixed(6)
      }
      listSenders = [...listSenders, temp]
    }
    return listSenders
  }
  return []
}

export const getListReceiver = async (contractAddress: string, userWallet: string)  => {
  if(window.ethereum) {
    const provider = new ethers.JsonRpcProvider(jsonRpc)
    const dPay = DPay__factory.connect(contractAddress, provider)
    const eventsFilter = dPay.filters._Deposit(undefined, userWallet, undefined, undefined, undefined)
    const events = await dPay.queryFilter(eventsFilter, 9570762, 'latest')
    let listSenders:ListSender[] = []
    
    for(let event of events) {
      const e = await dPay.paymentStream(Number(event.args[2]))
      const temp :ListSender = {
        id: Number(event.args[2]),
        sender: e.sender,
        recipient: e.receiver,
        amount: Number(ethers.formatUnits(e.amount, 6)),
        remainingBalance: Number(ethers.formatUnits(e.remainingBalance, 6)),
        ratePerSecond: Number(ethers.formatUnits(e.ratePerSecond, 6)),
        starttime: Number(e.startTime),
        availabeAmount: ((Math.round(+new Date()/1000) - Number(e.startTime))*Number(ethers.formatUnits(e.ratePerSecond, 6))).toFixed(6)
      }
      listSenders = [...listSenders, temp]
    }
    return listSenders
  }
  return []
}