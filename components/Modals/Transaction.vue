<script setup lang="ts">
// import and component
import datas from "../../protocol-contract/datas/chains.json";
import { useConnectWallet } from '../../stores/auth'
// interfaces
interface Props {
  linkTx: string
}
// data and props
const useWallet = useConnectWallet()

const props = defineProps<Props>()
defineEmits<{
  closeModal: []
}>()
// computed and watcher

// methods
const getBlockExplorer = () :string => {
  const chain = datas.filter((item) => item.chainId === useWallet.chainId)
  if(chain.length > 0) {
    return chain[0].block_explorer
  }
  return ''
}
// lifecycle
</script>

<template>
  <dialog id="modal_transaction" class="modal modal-open">
    <form method="dialog" class="modal-box">
      <button
        class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
        @click.prevent="$emit('closeModal')"
      >
        ✕
      </button>
      <div class="grid gap-4">
        <div class="text-lg font-bold flex items-center gap-2">
          <div>Transaction Submitted</div>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-6 h-6">
            <path fill-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm13.36-1.814a.75.75 0 10-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 00-1.06 1.06l2.25 2.25a.75.75 0 001.14-.094l3.75-5.25z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="text-sm">
          Your transaction submitted,
          If the transaction is success and you are doing cross-chain message, you can also track it on <a href="https://testnet.axelarscan.io/gmp/search" target="_blank" class="underline">axelarscan</a>
        </div>
        <a :href="getBlockExplorer() + '/tx/' + props.linkTx" target="_blank" class="flex items-center gap-2">
          <div>
            View your transaction 
          </div>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-[12px] h-[12px] rotate-[270deg]">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 4.5l15 15m0 0V8.25m0 11.25H8.25" />
          </svg>
        </a>
      </div>
    </form>
  </dialog>
</template>
