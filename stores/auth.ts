import { defineStore } from 'pinia'

export const useConnectWallet = defineStore('connectWallet', {
  state: (): State => ({
    chainId: 0,
    userWallet: ''
  }),
})

interface State {
  chainId: number,
  userWallet: string
}