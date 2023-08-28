<script setup lang="ts">
// import and component
import { useConnectWallet } from "../../stores/auth";
import datas from "../../protocol-contract/datas/chains.json";
import { getAllowance } from "../../hooks/useAllowance";
import { approveToken } from "../../hooks/useApprove";
import { calculate } from "../../protocol-contract/scripts/calculate-gas-fee"
import { ethers } from "ethers";
import { depositEth } from '../../hooks/useStream'
import { depositEthCross } from '../../hooks/useStreamCross'

// interfaces
import {FormStream} from '../../interfaces/globalInterfaces'
interface loading {
  crossFee: boolean,
  approve: boolean,
  tx: boolean
}

// data and props
const approved = ref<boolean>(false);
const useWallet = useConnectWallet();
const props = defineProps<FormStream>()
const loading = reactive({
  crossFee: false,
  approve: false,
  tx: false
})

const crossFee = ref<string>('')

const emit = defineEmits<{
  closeModal: [],
  openModalSuccess: [linkTx: string]
}>()

// computed and watcher
const nativeCurrenccy = computed(() :string => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    return chain[0].detail.nativeCurrency.symbol
  }
  return ''
})

// methods
const trimWallet = (text: string): string => {
  return text.slice(0,5) + '...' + text.slice(-3)
}

const getLogo = () :string => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    return chain[0].logo
  }
  return ''
}

const getBlockExplorer = () :string => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    return chain[0].block_explorer
  }
  return ''
}

const isApproved = async (): Promise<boolean> => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0 && props.totalAmount) {
    const ca = chain[0].chainId === 5 ? chain[0].usdc : chain[0].axlToken
    const allowance = await getAllowance(chain[0].contractAddress, useWallet.userWallet, ca as string)

    const value: BigInt = BigInt(props.totalAmount*1e6)
    if(allowance >= value) {
      return true
    }
    return false
  }
  return false
}

const approveTx = async () => {
  loading.approve = true
  try {
    const chain = datas.filter((item) => item.chainId === useWallet.chainId)
    if(chain.length > 0 && props.totalAmount) {
      const ca = chain[0].chainId === 5 ? chain[0].usdc : chain[0].axlToken
      await approveToken(chain[0].contractAddress, props.totalAmount*1e6, ca as string)
      approved.value = await isApproved()
    }
    loading.approve = false
  } catch (error) {
    console.log(error);
    loading.approve = false
  }
}

const deposit = async () => {
  loading.tx = true
  let txHash = ''

  try {
    const chain = datas.filter((item) => item.chainId === useWallet.chainId)[0]
    if(useWallet.chainId === 5) {
      txHash = await depositEth(chain.contractAddress, props)
    } else {
      txHash = await depositEthCross(chain.contractAddress, props, ethers.parseEther(crossFee.value)) 
    }
   
    loading.tx = false
    emit('closeModal')
    emit('openModalSuccess', txHash)

  } catch (error) {
    console.log(error);
    loading.tx = false
  }
}

// lifecycle
onMounted(async () => {
  loading.approve = true
  approved.value =  await isApproved();
  loading.approve = false

  loading.crossFee = true
  if(useWallet.chainId === 5) {
    crossFee.value = '0'
  } else {
    const d = await calculate(useWallet.chainId)
    crossFee.value = ethers.formatEther(BigInt(d as string))
  }
  
  loading.crossFee = false
})

</script>

<template>
  <dialog id="modal_deposit" class="modal modal-open">
    <form method="dialog" class="modal-box">
      <button 
        class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
        @click.prevent="$emit('closeModal')"
      >
        ✕
      </button>
      <h3 class="text-xl font-semibold pb-[1rem]">Confirm Stream</h3>
      <div class="border border-[hsl(215 28% 17%)]/0.2 rounded-[0.5rem] text-sm">
        <div class="flex gap-2 items-center justify-between px-[1rem] pb-[0.25rem] pt-[1rem]">
          <div class="font-semibold">Recipient</div>
          <a :href="getBlockExplorer() + '/address/' + props.recipient" target="_blank" class="flex items-center gap-[4px]">
            <div>{{ trimWallet(props.recipient as string) }}</div>
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-[12px] h-[12px] rotate-[270deg]">
              <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 4.5l15 15m0 0V8.25m0 11.25H8.25" />
            </svg>
          </a>
        </div>
        <div class="flex gap-2 items-center justify-between px-[1rem] py-[0.25rem]">
          <div class="font-semibold">Token</div>
          <div class="flex items-center gap-2">
            <LogosUsdc class="w-[20px] h-[20px]" />
            <div>(a)USDC</div>
          </div>
        </div>
        <div class="flex gap-2 items-center justify-between px-[1rem] pt-[0.25rem] pb-[0.75rem]">
          <div class="font-semibold">Flow Rate</div>
          <div>{{ props.flowAmount }} USDC /{{ props.flowRate }}</div>
        </div>
        <div class="flex gap-2 items-center justify-between px-[1rem] pt-[0.25rem] pb-[0.75rem]">
          <div class="font-semibold">Total Deposit</div>
          <div>{{ props.totalAmount }} USDC</div>
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
      <div class="grid grid-cols-2 gap-2">
        <button 
          class="btn no-animation"
          :class="{'btn-disabled': approved || loading.approve}"
          @click="approveTx"
        >
          Approve <span v-if="loading.approve" class="loading loading-spinner loading-xs"></span>
        </button>
        <button 
          class="btn btn-primary no-animation"
          :class="{'btn-disabled': !approved || loading.tx}"
          @click="deposit"
        >
          Confirm <span v-if="loading.tx" class="loading loading-spinner loading-xs"></span>
        </button>
      </div>
    </form>
  </dialog>
</template>
