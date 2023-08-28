<script setup lang="ts">
// import and component
import { trimWallet } from '../utils/helper'

// interfaces
import { FormStreamMore, ListSender } from '../interfaces/globalInterfaces';

interface Props {
  data: ListSender[],
  loading: boolean,
  listTabs: string[],
  activeTab: string
}

// data and props
const props = defineProps<Props>()
const listData = reactive<ListSender[]>([])
const openModalInput = ref<boolean>(false)
const activeId = ref<number>(0)
const openModalFund = ref<boolean>(false)
const isOpenModalTransaction = ref<boolean>(false)
const txHash = ref<string>('')
const formAddFund = reactive<FormStreamMore>({
  id: 0,
  totalAmount: 0,
  recipient: '',
  remainingBalance: 0
})
defineEmits<{
  changeTab: [value: string]
}>()

// computed and watcher
watch(props.data, (newData) => {
  mutateData(newData)
})

// methods
const mutateData = (data: ListSender[]) => {
  listData.splice(0, listData.length, ...data)
  setInterval(() => {
    listData.forEach((item) => {
      item.availabeAmount = ((Math.round(+new Date()/1000) - item.starttime)*item.ratePerSecond).toFixed(6)
    }, 1000)
  })
}

const handleAddAgain = (id: number, amount: number) => {
  const detailStream = listData.filter((item) => item.id === id)
  console.log(detailStream, id, amount)
  if(detailStream.length > 0) {
    formAddFund.id = id
    formAddFund.totalAmount = amount
    formAddFund.recipient = detailStream[0].recipient
    formAddFund.remainingBalance = detailStream[0].remainingBalance
    openModalFund.value = true
    console.log('here')
  }
  
}

const openModalTransaction = (tx: string) => {
  txHash.value = tx
  isOpenModalTransaction.value = true
}
// lifecycle
onMounted(() => {
  mutateData(props.data)
})
</script>

<template>
  <div class="w-full mt-[5rem] bg-white rounded-xl p-4">
    <div class="tabs">
      <div v-for="(item, index) in listTabs" :key="index" class="tab tab-lg tab-lifted"
        :class="{ 'tab-active': activeTab === item }" @click="$emit('changeTab', item)">
        {{ item }}
      </div>
    </div>
    <div class="overflow-x-auto">
      <table class="table text-[1rem] mt-[2rem]">
        <!-- head -->
        <thead class="text-sm">
          <tr>
            <th>Stream ID</th>
            <th>Sender</th>
            <th>Recipient</th>
            <th>Total Amount</th>
            <th>Remaining Balance</th>
            <th>Withdrawable By Recipient</th>
          </tr>
        </thead>
        <tbody class="text-sm">
          <template v-if="props.loading">
            <tr>
              <td><span class="loading loading-dots loading-md"></span></td>
            </tr>
          </template>
          <template v-else>
            <template v-if="listData.length > 0">
              <tr v-for="(item, index) in listData">
                <td class="whitespace-nowrap">{{ item.id }}</td>
                <td class="whitespace-nowrap">{{ trimWallet(item.sender) }}</td>
                <td class="whitespace-nowrap">{{ trimWallet(item.recipient) }}</td>
                <td class="whitespace-nowrap">{{ item.amount }} USDC</td>
                <td class="whitespace-nowrap">{{ item.remainingBalance }} USDC</td>
                <td class="whitespace-nowrap">{{ item.availabeAmount }} USDC</td>
                <td>
                  <div v-if="props.activeTab !== 'Incoming'" class="flex gap-2">
                    <button class="btn no-animation btn-primary text-xs" @click="(openModalInput = true, activeId = item.id)">Add fund</button>
                    <button class="btn no-animation text-xs">Cancle</button>
                  </div>
                </td>
              </tr>
            </template>
            <tr v-else>
              <td colspan="7">
                <div class="flex flex-col justify-center items-center gap-4 py-8">
                  <IconsEmpty />
                  <div class="font-bold">
                    You dont have any stream
                  </div>
                </div>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
    <!-- modal start -->
    <ModalsModalInputDepositAgain 
      v-if="openModalInput"
      :id="activeId"
      @close-modal="openModalInput = false"
      @submit="handleAddAgain"
    />
    <ModalsDepositAgain 
       v-if="openModalFund"
      :id="formAddFund.id"
      :total-amount="formAddFund.totalAmount"
      :recipient="formAddFund.recipient"
      :remaining-balance="formAddFund.remainingBalance"
      @close-modal="openModalFund = false"
      @open-modal-success="openModalTransaction"
    />
    <ModalsTransaction 
      v-if="isOpenModalTransaction" 
      :link-tx="txHash" 
      @close-modal="isOpenModalTransaction = false"
    />
    <!-- end modal  -->
  </div>
</template>