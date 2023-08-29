<script setup lang="ts">
// import and component
import datas from '../../protocol-contract/datas/chains.json'
import { useConnectWallet } from '../../stores/auth'
import { getBalance } from '../../hooks/useBalance'
import { ethers } from 'ethers'
// interfaces
interface props {
  id: number
}

// props and data
const useWallet = useConnectWallet()
const balance = ref<BigInt>(0n)
const amount = ref<number | null>(null)
const errors = ref<string[]>([])
const loading = ref<boolean>(false)
const props =defineProps<props>()

const emit = defineEmits<{
  closeModal: [],
  submit: [id: number, amount: number]
}>()
// computed and watcher

// methods
const getUsdcBalance = async () => {
  loading.value = true
  const chain = datas.filter((item) => item.chainId === useWallet.chainId);
  if (chain.length > 0) {
    const contractAddress =
      useWallet.chainId === 5 ? chain[0].usdc : chain[0].axlToken;
    balance.value = await getBalance(
      useWallet.userWallet,
      contractAddress as string
    );
  } else {
    balance.value = 0n;
  }
  loading.value = false
};

const handleSubmit = () => {
  errors.value = []
  const chain = datas.filter((item) => item.chainId === useWallet.chainId);
  if (chain.length === 0) {
    errors.value = [...errors.value, "unspoorted network"]
  } else {
    if (amount.value) {
      if (amount.value > 200) {
        errors.value = [...errors.value, "maximum amount to deposit is 200 (a)USDC"]
      } else {
        if(amount.value > Number(ethers.formatUnits(balance.value, 6))) {
          errors.value = [...errors.value, "insufficient balance"]
        } else {
          emit('submit', props.id, amount.value)
          emit('closeModal')
        }
      }
    } else {
      errors.value = [...errors.value, "amount is required"]
    }
  }
}
// lifecycle
onMounted(async () => {
  await getUsdcBalance()
})
</script>

<template>
  <dialog id="modal_deposit_input_again" class="modal modal-open">
    <form method="dialog" class="modal-box">
      <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2" @click.prevent="$emit('closeModal')">
        ✕
      </button>
      <div class="py-2">
        <h3 class="text-xl font-semibold pb-[1rem]">Add More Fund</h3>
        <div class="form-control w-full">
          <label class="label">
            <span class="label-text font-bold">Total Amount</span>
          </label>
          <input type="text" v-model="amount" placeholder="Enter amount" class="input input-bordered w-full" />
          <label class="label">
            <span class="label-text text-xs">Maximum 200 (a)USDC</span>
            <span class="label-text text-xs">Your balance : {{ ethers.formatUnits(balance, 6) }} (a)USDC</span>
          </label>
        </div>
      </div>
      <div v-if="errors.length > 0" class="alert alert-error my-2">
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
      <button 
        class="btn no-animation w-full" 
        :class="{'btn-disabled': loading}"
        @click.prevent="handleSubmit"
      >
        Add more fund
      </button>
    </form>
  </dialog>
</template>