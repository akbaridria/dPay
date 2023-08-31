<script setup lang="ts">
// import and component
import { useConnectWallet } from '../../stores/auth'
import { getFaucet } from '../../hooks/useFaucet'
// interfaces

// data and props
const useWallet = useConnectWallet()
const loading = ref<boolean>(false)

const emit = defineEmits<{
  closeModal: [],
  openModalTx: [value: string]
}>()
// computed and watcher

// methods
const faucet = async () => {
  try {
    loading.value = true
    const txHash = await getFaucet(useWallet.userWallet)
    emit('closeModal')
    emit('openModalTx', txHash)
    loading.value = false
  } catch (error) {

    loading.value = false
  }
}
</script>

<template>
  <dialog id="modal_deposit_again" class="modal modal-open">
    <form method="dialog" class="modal-box">
      <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2" @click.prevent="$emit('closeModal')">
        ✕
      </button>
      <h3 class="text-xl font-semibold pb-[1rem]">Faucet</h3>
      <div class="border border-[hsl(215 28% 17%)]/0.2 rounded-[0.5rem] text-sm">
        <div class="flex gap-2 items-center p-4">
          <LogosUsdc class="w-[24px] h-[24px]" />
          <div class="font-semibold text-base">200 USDC</div>
        </div>
      </div>
      <div class="alert alert-warning mt-4">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span>
          To stream on ethereum/goerli you can use this faucet.
          but, for axlUsdc faucet you can go to axelar discord <a href="https://discord.com/invite/aRZ3Ra6f7D"
            target="_blank" class="underline font-semibold">here</a> and goto <span class="font-semibold">#faucet</span> channel
        </span>
      </div>
      <button 
        class="btn no-animation w-full mt-4"
        :class="{'btn-disabled': loading || useWallet.chainId != 5}"
        @click="faucet"
      >
       <template v-if="useWallet.chainId === 5">
        Fuacet <span v-if="loading" class="loading loading-spinner loading-xs"></span>
       </template>
       <template v-else>
        <div>Wrong network</div>
       </template>
      </button>
    </form>
  </dialog>
</template>