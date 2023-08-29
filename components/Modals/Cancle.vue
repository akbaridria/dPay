<script setup lang="ts">
// import and component
import { trimWallet } from '../../utils/helper'
import { useConnectWallet } from '../../stores/auth'
import datas from '../../protocol-contract/datas/chains.json'
import { cancleStream } from '../../hooks/useStream'

// interfaces
import { FormCancle } from '../../interfaces/globalInterfaces'
// data and props
const loading = ref<boolean>();
const props = defineProps<FormCancle>()
const useWallet = useConnectWallet()
const errors = ref<string[]>([])

const emit = defineEmits<{
  closeModal: [],
  openModalSuccess: [txHash: string]
}>()

// computed and watcher

// methods
const handleSubmit = async () => {
  if (useWallet.chainId !== 5) {
    errors.value = [...errors.value, "Supported network for cancle stream is goerli(ethereum) chain only"]
  } else {
    try {
      loading.value = true
      const chain = datas.filter((item) => item.chainId === useWallet.chainId)
      const hash = await cancleStream(chain[0].contractAddress, props.id)
      loading.value = false
      emit('closeModal')
      emit('openModalSuccess', hash)
    } catch (error) {
      console.log(error);
      loading.value = false
    }
  }
}
// lifecycle
onMounted(async () => {

})

</script>

<template>
  <dialog id="modal_deposit_again" class="modal modal-open">
    <form method="dialog" class="modal-box">
      <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2" @click.prevent="$emit('closeModal')">
        ✕
      </button>
      <h3 class="text-xl font-semibold pb-[1rem]">Cancle Stream</h3>
      <div class="border border-[hsl(215 28% 17%)]/0.2 rounded-[0.5rem] text-sm">
        <div class="flex gap-2 items-center justify-between px-[1rem] pb-[0.25rem] pt-[1rem]">
          <div class="font-semibold">Recipient</div>
          <div>{{ trimWallet(props.recipient) }}</div>
        </div>
        <div class="flex gap-2 items-center justify-between px-[1rem] py-[0.25rem]">
          <div class="font-semibold">Token</div>
          <div class="flex items-center gap-2">
            <LogosUsdc class="w-[20px] h-[20px]" />
            <div>(a)USDC</div>
          </div>
        </div>
        <div class="flex gap-2 items-center justify-between px-[1rem] pt-[0.25rem] pb-[0.25rem]">
          <div class="font-semibold">Remaining Balance</div>
          <div>{{ props.remainingBalance }} USDC</div>
        </div>
        <div class="flex gap-2 items-center justify-between px-[1rem] pt-[0.25rem] pb-[0.75rem]">
          <div class="font-semibold">Total Deposit</div>
          <div>{{ props.totalDeposit }} USDC</div>
        </div>
      </div>
      <div v-if="errors.length > 0" class="alert alert-error mt-4">
        <div>
          <div v-for="(item, index) in errors" :key="index" class="text-sm flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-4 w-4" fill="none"
              viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{{ item }}</span>
          </div>
        </div>
      </div>
      <button class="btn no-animation mt-4 w-full" :class="{ 'btn-disabled': loading }" @click="handleSubmit">
        Cancle Stream <span v-if="loading" class="loading loading-spinner loading-xs"></span>
      </button>
    </form>
  </dialog>
</template>
