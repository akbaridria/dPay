<script setup lang="ts">
// import and component
import { ethers } from "ethers";
import { useConnectWallet } from '../stores/auth'
import { MetaMaskInpageProvider } from "@metamask/providers";

// interfaces
declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider
  }
}
import { DetailChain } from '../interfaces/globalInterfaces'

// data and props
const useConnect = useConnectWallet()

// methods
const init = async () => {
  if ((window as any).ethereum === null) {
    console.log('metamask is not installed')
  } else {
    const provider = new ethers.BrowserProvider((window as any).ethereum);
    const signer = (await provider.getSigner()).address
    const chainId = provider._network.chainId
    useConnect.$patch({
      chainId: Number(chainId),
      userWallet: signer
    })
  }
}

const connectWallet = async () => {
  const provider = new ethers.BrowserProvider((window as any).ethereum);
  await provider.send("eth_requestAccounts", []);
  init()
}

const switchWallet = async (detailChain:DetailChain) => {
  if (window.ethereum) {
    try {
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId:detailChain.chainId }]
      });
    } catch (err: any) {
      if (err.code === 4902) {
        await window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [detailChain]
        })
      }
    }
  }
}

// lifecycle
onMounted(async () => {
  if (window.ethereum) {
    init()
    window.ethereum.on('chainChanged', (e: any) => {
      useConnect.$patch({ chainId: Number(BigInt(e)) })
    })

    window.ethereum.on('accountsChanged', (e: any) => {
      console.log("accountChange")
      if (e.length === 0) {
        useConnect.$patch({ chainId: 0, userWallet: '' })
      } else {
        useConnect.$patch({ userWallet: e[0] })
      }
    })
  }
})
</script>
<template>
  <div>
    <Header @connect-wallet="connectWallet" @switch-wallet="switchWallet" />
    <Menus />
    <slot />
    <Footer />
  </div>
</template>
