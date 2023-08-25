<script setup lang="ts">
// import and component
import { ethers } from "ethers";
import { useConnectWallet } from '../stores/auth'
import { MetaMaskInpageProvider } from "@metamask/providers";

// interfaces
declare global{
  interface Window {
    ethereum?:MetaMaskInpageProvider
  }
}

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

// lifecycle
onMounted(async () => {
  await connectWallet()
  if (window.ethereum) {
    window.ethereum.on('chainChanged', (e: any) => {
      useConnect.$patch({chainId: Number(BigInt(e))})
    })

    window.ethereum.on('accountsChanged', (e: any) => {
      console.log("accountChange")
      if (e.length === 0) {
        useConnect.$patch({ chainId: 0, userWallet: ''})
      } else {
        useConnect.$patch({ userWallet: e[0]})
      }
    })
  }
})
</script>
<template>
  <div>
    <Header />
    <Menus />
    <slot />
    <Footer />
  </div>
</template>
