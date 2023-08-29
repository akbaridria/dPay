<script setup lang="ts">
// import and component
import { getRewardDetail, claimReward } from '../hooks/useReward'
import datas from '../protocol-contract/datas/chains.json'
import { useConnectWallet } from '../stores/auth'
import faqs from '../datas/faq.json'
import { ethers } from 'ethers';

// interfaces
import { FormReward } from '../interfaces/globalInterfaces'

interface loading {
  balance: boolean,
  claim: boolean
}

// data and props
const useWallet = useConnectWallet()
const loading = reactive<loading>({
  balance: false,
  claim: false
})
const txHash = ref<string>('')
const rewardDetail = reactive<FormReward>({
  isEntity: false,
  reward: 0,
  lastClaimTime: 0
})
const openToast = ref<boolean>(false)
const openModalTx = ref<boolean>(false)

// computed and watcher
watch(() => useWallet.userWallet, async () => {
  await getReward()
})

// methods
const getReward = async () => {
  loading.balance = true
  const chain = datas.filter((item) => item.chainId === 5)
  if (chain.length > 0) {
    const d = await getRewardDetail(useWallet.userWallet, chain[0].contractAddress)
    rewardDetail.isEntity = d.isEntity
    rewardDetail.reward = d.reward
    rewardDetail.lastClaimTime = d.lastClaimTime
  }
  loading.balance = false
}

const handleSubmit = async () => {
  if(useWallet.chainId !== 5) {
    openToast.value = true
    setTimeout(() => {
      openToast.value = false
    }, 3000);
  } else {
    try {
    const chain = datas.filter((item) => item.chainId === 5)[0]
      loading.claim = true
      txHash.value = await claimReward(chain.contractAddress)
      loading.claim = false
      openModalTx.value = true
    } catch (error) {
      console.log(error)
      loading.claim = false
    }
  }
}

// lifecycle
onMounted(async () => {
  await getReward()
})
</script>

<template>
  <div>
    <div v-if="openToast" class="toast toast-end toast-top z-[1000]">
      <div class="alert alert-error">
        <span class="font-bold">Unsopported network, <br> change it to goerli/ethereum network.</span>
      </div>
    </div>
    <div class="relative bg-black grid gap-[2rem]">
      <img class="absolute top-0 right-0 h-full" src="images/looper-3.svg" alt="">
      <div class="max-w-[1030px] mx-auto">
        <div class="px-4 py-[7rem] text-white text-center flex flex-col gap-[1rem] items-center justify-center">
          <div class="text-[2rem]">
            Your current reward
          </div>
          <div class="text-[6rem] font-semibold">
            {{ ethers.formatUnits(rewardDetail.reward, 6) }} <span v-if="loading.balance" class="loading loading-infinity loading-lg"></span> <span class="text-[3rem] font-semibold">(a)USDC</span>
          </div>
          <button 
            @click="handleSubmit" 
            class="btn no-animation"
            :class="{'btn-disabled': loading.balance || !rewardDetail.isEntity}"
          >
            Claim Reward <span v-if="loading.claim" class="loading loading-spinner loading-xs"></span>
          </button>
        </div>
      </div>
    </div>
    <div class="bg-cwhite-100">
      <div class="max-w-[1030px] mx-auto">
        <div class="py-[5rem] px-[1rem]">
          <div class="text-[2.5rem] text-center font-semibold">Let's answer some of <br> your questions</div>
          <div class="grid gap-[2rem] py-[5rem]">
            <Accordion v-for="(item, index) in faqs.faq" :key="index" :question="item.question" :answer="item.answer" />
          </div>
        </div>
      </div>
    </div>
    <ModalsTransaction 
      v-if="openModalTx"
      :link-tx="txHash"
      @close-modal="openModalTx = false"
    />
  </div>
</template>