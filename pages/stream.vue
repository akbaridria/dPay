<script setup lang="ts">
// import and component
import { getListSenders, getListReceiver } from '../hooks/useStream'
import { useConnectWallet } from '../stores/auth'
import datas from '../protocol-contract/datas/chains.json'
import { ListSender } from '../interfaces/globalInterfaces';

useHead({
  title: 'dPay | Stream'
})

// interfaces

// data and props
const useWallet = useConnectWallet();
const listData:ListSender[] = reactive([])
const loadingDashboard = ref<boolean>(false)
const listTabs = ref<string[]>(['Incoming', 'Outgoing'])
const activeTab = ref<string>('Incoming')

// computed and watcher
useWallet.$subscribe(async () => {
  const d = await getSenders(activeTab.value)
  listData.splice(0, listData.length, ...d)
});

watch(() => activeTab.value, async (newData) => {
  const d = await getSenders(newData)
  listData.splice(0, listData.length, ...d)
})

// methods
const getSenders = async (tab:string) => {
  loadingDashboard.value = true
  if(useWallet.chainId > 0) {
    const chain = datas.filter((item) => item.chainId === 5)
    let d: ListSender[] = []
    if(tab === 'Incoming') {
      d = await getListReceiver(chain[0].contractAddress, useWallet.userWallet)
    } else {
      d = await getListSenders(chain[0].contractAddress, useWallet.userWallet)
    }
    loadingDashboard.value = false
    return d
  }
  loadingDashboard.value = false
  return []
}

// lifecycle
onMounted(async () => {
 const d =  await getSenders(activeTab.value)
 listData.splice(0, listData.length, ...d)
})

</script>

<template>
  <div class="bg-cwhite-100">
    <div class="max-w-[1030px] mx-auto px-4 py-[7rem] text-black">
      <FormStream />
      <Dashboard 
        :data="listData" 
        :loading="loadingDashboard"
        :list-tabs="listTabs"
        :active-tab="activeTab"
        @change-tab="activeTab = $event"
      />
      
    </div>
  </div>
</template>