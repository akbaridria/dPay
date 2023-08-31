<script setup lang="ts">
// import and component
import datas from '../protocol-contract/datas/chains.json';
import { minidenticon } from 'minidenticons'

import chains from '../protocol-contract/datas/chains.json'
import { useConnectWallet } from '../stores/auth'
import { DetailChain } from 'interfaces/globalInterfaces';

// interfaces

// data and props
const useWallet = useConnectWallet();
const emit = defineEmits<{
  connectWallet: [],
  switchWallet: [value: DetailChain]
}>()

const txHash = ref<string>('')
const openModalFaucet = ref<boolean>(false)
const openModalTx = ref<boolean>(false)

// computed and watcher
const validNetwork = computed(() :boolean => {
  const chain = chains.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    return true
  }
  return false
})

// methods
const svgUri = (): string => {
  return 'data:image/svg+xml;utf8,' + encodeURIComponent(minidenticon(useWallet.userWallet, 0, 0))
}

const trimWallet = (text: string): string => {
  return text.slice(0,5) + '...' + text.slice(-3)
}
const getChain = () => {
  const chain = chains.filter((item) => item.chainId === useWallet.chainId)
  return chain[0]
}

const openModalTransaction = (tx: string) => {
  txHash.value = tx
  openModalTx.value = true
}
// lifecycle
</script>

<template>
  <div class="sticky top-0 bg-black z-[100]">
    <div class="container mx-auto p-4">
      <div class="flex justify-between">
        <div><LogosDPayLogos class="w-[56px] h-[56px] fill-white" /></div>
        <div class="flex items-center gap-2">
          <button
            class="bg-cblack-100 px-[1.25rem] py-[1rem] rounded-xl hover:brightness-150 transition-all flex items-center gap-2 text-white"
            @click="openModalFaucet = true"
          >
            Faucet
          </button>
          <div 
            v-if="useWallet.chainId > 0"
            class="dropdown"
          >
            <label 
              tabindex="0" 
              class="cursor-pointer flex gap-2 items-center bg-cblack-100 text-white px-[1.25rem] py-[1rem] rounded-xl hover:brightness-150 transition-all"
            >
              <template v-if="!validNetwork">
                <div>Wrong network</div>
                <div class="w-[8px] h-[8px] rounded-full bg-red-600"></div>
              </template>
              <div 
                v-else
                class="flex items-center gap-2"
              >
                <component :is="getChain().logo" class="w-[24px] h-[24px]" />
                <div>{{ getChain().detail.chainName }}</div>
              </div>
              <IconsChevron class="fill-white w-[24px] h-[24px] rotate-[90deg]" />
            </label>
            <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box mt-[0.5rem] w-60">
              <li v-for="(item, index) in datas" :key="index">
                <div @click="emit('switchWallet', item.detail as unknown as DetailChain)">
                  <component :is="item.logo" class="w-[24px] h-[24px]" />
                  {{ item.detail.chainName }}
                  <div v-if="item.chainId === useWallet.chainId" class="w-[8px] h-[8px] rounded-full bg-green-600"></div>
                </div>
              </li>
            </ul>
          </div>
          <button 
            class="bg-cblack-100 px-[1.25rem] py-[1rem] rounded-xl hover:brightness-150 transition-all flex items-center gap-2 text-white"
            @click="emit('connectWallet')"
            >
           <template v-if="useWallet.chainId === 0 ">
              <LogosMetamask class="w-[18px] h-[18px]" />
              <div class="hidden sm:block">Connect Metamask</div>
           </template>
           <div 
            v-else
            class="flex gap-2"
           >
            <div class="bg-white rounded-full"><img :src="svgUri()" alt="" width="24" height="24"></div>
            <div>{{ trimWallet(useWallet.userWallet) }}</div>
           </div>
          </button>
        </div>
      </div>
    </div>
    <!-- start modal   -->
    <ModalsFaucet 
      v-if="openModalFaucet"
      @open-modal-tx="openModalTransaction"
      @close-modal="openModalFaucet = false"
    />

    <ModalsTransaction 
      v-if="openModalTx"
      :link-tx="txHash"
      @close-modal="openModalTx = false"
    />
    <!-- end modal  -->
  </div>
</template>