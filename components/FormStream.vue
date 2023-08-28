<script setup lang="ts">
// import and component
import { getBalance } from "../hooks/useBalance";
import { useConnectWallet } from "../stores/auth";
import datas from "../protocol-contract/datas/chains.json";
import { ethers } from "ethers";

// interfaces
import { FormStream } from "../interfaces/globalInterfaces";
// data and props
const useWallet = useConnectWallet();
const rates = reactive<string[]>([
  "seconds",
  "hours",
  "days",
  "months",
  "years",
]);
const balance = ref<BigInt>(0n);
const errors = ref<string[]>([]);
const form = reactive<FormStream>({
  recipient: null,
  flowAmount: null,
  flowRate: "days",
  totalAmount: null,
});
const openModal = ref<boolean>(false);
const isOpenModalTransaction = ref<boolean>(false);
const txHash = ref<string>('')

// computed and wathcer
useWallet.$subscribe(async () => {
  await getUsdcBalance();
});

// methods
const getUsdcBalance = async () => {
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
};

const openModalTransaction = (tx: string) => {
  txHash.value = tx
  isOpenModalTransaction.value = true
}

const handleSubmit = () => {
  errors.value = [];
  const chain = datas.filter((item) => item.chainId === useWallet.chainId);
  if (useWallet.chainId === 0) {
    errors.value = [...errors.value, "Wallet not connected"];
  } else {
    if (chain.length === 0) {
      errors.value = [...errors.value, "Unsupported network"];
    } else {
      if (form.recipient && form.flowAmount && form.totalAmount) {
        const b = ethers.formatUnits(balance.value, 6);
        if (form.flowAmount < 100) {
          errors.value = [
            ...errors.value,
            "Flow rate amount should be higher or equal to 100",
          ];
        }
        if (form.flowAmount > form.totalAmount) {
          errors.value = [
            ...errors.value,
            "Total amount to deposit should be higher than flow rate",
          ];
        }
        if (
          form.recipient?.toLowerCase() === useWallet.userWallet.toLowerCase()
        ) {
          errors.value = [
            ...errors.value,
            "recipient should not be the same as the your connected wallet address",
          ];
        }
        if (form.totalAmount > 200) {
          errors.value = [
            ...errors.value,
            "Maximum total amount to deposit is 200 USDC",
          ];
        }
        if (form.totalAmount > Number(b)) {
          errors.value = [...errors.value, "Insufficient balance"];
        }
      } else {
        if (!form.flowAmount) {
          errors.value = [...errors.value, "Flow amount is required"];
        }
        if (!form.recipient) {
          errors.value = [...errors.value, "Recipient is required"];
        }
        if (!form.totalAmount) {
          errors.value = [...errors.value, "Total amount is required"];
        }
      }
    }
  }
  if (errors.value.length === 0) {
    openModal.value = true;
  }
};

// lifecycle
onMounted(async () => {
  if (useWallet.chainId > 0) {
    getUsdcBalance();
  }
});
</script>

<template>
  <div class="flex items-center justify-center">
    <div class="bg-white rounded-lg p-[2rem] w-full max-w-[600px]">
      <div class="grid items-center justify-center gap-4">
        <div>
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text text-[1rem] font-bold"
                >Receiver Wallet Address</span
              >
            </label>
            <input
              type="text"
              v-model="form.recipient"
              placeholder="Enter recipient wallet's address"
              class="input input-bordered w-full text-[14px]"
            />
          </div>
        </div>
        <div class="grid sm:grid-cols-2 gap-2">
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text text-[1rem] font-bold">Token</span>
            </label>
            <div class="border border-[hsl(215 28% 17%)]/0.2 rounded-[0.5rem]">
              <div class="flex gap-2 items-center px-[1rem] py-[0.75rem]">
                <LogosUsdc class="w-[20px] h-[20px]" />
                <div>(a)Usdc</div>
              </div>
            </div>
          </div>
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text text-[1rem] font-bold">Flow Rate</span>
            </label>
            <div class="join">
              <div>
                <div>
                  <input
                    v-model="form.flowAmount"
                    type="number"
                    class="input input-bordered join-item"
                    placeholder="Enter amount"
                  />
                </div>
              </div>
              <select
                v-model="form.flowRate"
                class="select select-bordered join-item !pr-[1rem]"
              >
                <option disabled selected>Rate</option>
                <option
                  v-for="(item, index) in rates"
                  :key="index"
                  :value="item"
                >
                  /{{ item }}
                </option>
              </select>
            </div>
            <label class="label">
              <span class="label-text-alt">Minimum: 100 (a)Usdc</span>
            </label>
          </div>
        </div>
        <div>
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text text-[1rem] font-bold">Total Amount</span>
            </label>
            <input
              v-model="form.totalAmount"
              type="number"
              placeholder="Enter total amount to stream"
              class="input input-bordered w-full text-[14px]"
            />
            <label class="label">
              <span class="label-text-alt"
                >Maximum 200 (a)USDC per-transaction</span
              >
              <span class="label-text-alt"
                >(a)USDC balance: {{ ethers.formatUnits(balance, 6) }}</span
              >
            </label>
          </div>
        </div>
        <div v-if="errors.length > 0" class="alert alert-error">
          <div>
            <div
              v-for="(item, index) in errors"
              :key="index"
              class="text-sm flex items-center gap-2"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="stroke-current shrink-0 h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <span>{{ item }}</span>
            </div>
          </div>
        </div>

        <button
          class="w-full px-[1.25rem] py-[1.25rem] bg-cblack-100 rounded-xl text-white hover:brightness-50 transition-all"
          @click="handleSubmit"
        >
          Send Stream
        </button>
      </div>
    </div>

    <ModalsTransaction 
      v-if="isOpenModalTransaction" 
      :link-tx="txHash" 
      @close-modal="isOpenModalTransaction = false"
    />

    <ModalsDeposit
      v-if="openModal"
      :recipient="form.recipient"
      :flow-amount="form.flowAmount"
      :flow-rate="form.flowRate"
      :total-amount="form.totalAmount"
      @close-modal="openModal = false"
      @open-modal-success="openModalTransaction"
    />
  </div>
</template>
