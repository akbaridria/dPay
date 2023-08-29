<script setup lang="ts">
// import and component
import { ethers } from 'ethers'
import { useConnectWallet } from '../../stores/auth'
import datas from '../../protocol-contract/datas/chains.json'
import { calculate } from "../../protocol-contract/scripts/calculate-gas-fee"
import { withdraw } from '../../hooks/useStream'
import { withdrawCross } from '../../hooks/useStreamCross'

// interfaces
import { FormWithdraw } from '../../interfaces/globalInterfaces'
interface loading {
  crossFee: boolean,
  tx: boolean
}

// props and data
const useWallet = useConnectWallet()
const loading = reactive<loading>({
  crossFee: false,
  tx: false
})
const crossFee = ref<string>('')
const isSupportedNetwork = ref<boolean>(false)
const errors = ref<string[]>([])
const props = defineProps<FormWithdraw>()
const emit = defineEmits<{
  closeModal: [],
  submit: [txHash: string]
}>()

// computed and watcher
const nativeCurrenccy = computed(() :string => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    return chain[0].detail.nativeCurrency.symbol
  }
  return ''
})

watch(() => useWallet.chainId, async () => {
  setSupportedNetwork()
  if(isSupportedNetwork.value) {
    await getCrossChainFee()
  }
})

// methods
const getLogo = () :string => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    return chain[0].logo
  }
  return ''
}

const getCrossChainFee = async () => {
  loading.crossFee = true
  if(useWallet.chainId === 5) {
    crossFee.value = '0'
  } else {
    const d = await calculate(useWallet.chainId)
    crossFee.value = ethers.formatEther(BigInt(d as string))
  }
  loading.crossFee = false
}

const setSupportedNetwork = () => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    isSupportedNetwork.value = true
  } else {
    isSupportedNetwork.value = false
  }
}
const handleSubmit = async () => {
  errors.value = []
  if(!isSupportedNetwork.value) {
    errors.value = [...errors.value, "Unsopported Network"]
  } else {
    try {
      loading.tx = true
      let hash = ''
      const chain = datas.filter((item) => item.chainId === useWallet.chainId)[0]
      if(useWallet.chainId === 5) {
        hash = await withdraw(chain.contractAddress, props.id);
      } else {
        hash = await withdrawCross(chain.contractAddress, props.id, ethers.parseEther(crossFee.value))
      }
      emit('submit', hash)
      emit('closeModal')
      loading.tx = false
    } catch (error) {
      console.log(error);
      loading.tx = false
    }
  }
}

// lifecycle
onMounted(async () => {
  setSupportedNetwork()
  if(isSupportedNetwork.value) {
    await getCrossChainFee()
  }
})
</script>

<template>
  <dialog id="modal_deposit_input_again" class="modal modal-open">
    <form method="dialog" class="modal-box">
      <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2" @click.prevent="$emit('closeModal')">
        ✕
      </button>
      <h3 class="text-xl font-semibold pb-[1rem]">Withdraw</h3>
      <div class="border border-[hsl(215 28% 17%)]/0.2 rounded-[0.5rem] text-sm">
        <div class="flex gap-2 items-center justify-between px-[1rem] py-[1rem]">
          <!-- <div class="font-semibold">Token</div> -->
          <div class="flex items-center gap-2">
            <LogosUsdc class="w-[20px] h-[20px]" />
            <div>(a)USDC</div>
          </div>
          <div class="font-semibold">
            ~ {{ props.totalAmount }} USDC
          </div>
        </div>
      </div>
      <div class="text-sm">
        <div class="flex gap-2 items-center justify-between px-[1rem] pb-[0.25rem] pt-[0.75rem]">
          <div class="font-semibold">Cross-chain gas fee</div>
          <div class="flex items-center gap-2"> <span v-if="loading.crossFee" class="loading loading-infinity loading-xs"></span> {{ crossFee }} {{ nativeCurrenccy }}</div>
        </div>
        <div class="flex gap-2 text-sm items-center justify-between px-[1rem] pt-[0.25rem] pb-[0.75rem]">
          <div class="font-semibold">Order routing</div>
          <div class="flex items-center gap-2">
            <div class="flex items-center">
              <div class="w-[16px] h-[16px] rounded-full bg-gray-300"></div>
              <template v-if="useWallet.chainId != 5">
                <div>----</div>
                <component :is="getLogo()" class="w-[16px] h-[16px]" />
              </template>
              <div>----</div>
              <LogosEthereum class="w-[16px] h-[16px]" />
              
              <div>----</div>
              <LogosDPayLogos class="w-[16px] h-[16px] fill-black" />
            </div>
          </div>
        </div>
      </div>
      <div v-if="errors.length > 0" class="alert alert-error my-4">
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
        :class="{'btn-disabled': loading.crossFee || loading.tx}"
        @click.prevent="handleSubmit"
      >
        Withdraw  <span v-if="loading.crossFee || loading.tx" class="loading loading-spinner loading-xs"></span>
      </button>
    </form>
  </dialog>
</template>