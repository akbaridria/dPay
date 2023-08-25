<script setup lang="ts">

</script>

<template>
  <div class="flex items-center justify-center">
    <div class="bg-white rounded-lg p-[2rem] w-full max-w-[600px]">
      <div class="grid items-center justify-center gap-4">
        <div>
          <div class="form-control w-full ">
            <label class="label">
              <span class="label-text text-[1rem] font-bold">Receiver Wallet Address</span>
            </label>
            <input type="text" placeholder="Enter recipient wallet's address"
              class="input input-bordered w-full text-[14px]" />
          </div>
        </div>
        <div class="grid grid-cols-2 gap-2">
          <div class="form-control w-full ">
            <label class="label">
              <span class="label-text text-[1rem] font-bold">Token</span>
            </label>
            <input type="text" placeholder="Enter recipient wallet's address"
              class="input input-bordered w-full text-[14px]" />
          </div>
          <div class="form-control w-full ">
            <label class="label">
              <span class="label-text text-[1rem] font-bold">Token</span>
            </label>
            <div class="join">
              <div>
                <div>
                  <input class="input input-bordered join-item" placeholder="Search" />
                </div>
              </div>
              <select class="select select-bordered join-item">
                <option disabled selected>Filter</option>
                <option>Sci-fi</option>
                <option>Drama</option>
                <option>Action</option>
              </select>
            </div>
          </div>
        </div>
        <div>
          <div class="form-control w-full ">
            <label class="label">
              <span class="label-text text-[1rem] font-bold">Amount</span>
            </label>
            <input type="text" placeholder="Enter recipient wallet's address"
              class="input input-bordered w-full text-[14px]" />
          </div>
        </div>
        <div class="alert alert-info text-sm">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <span>Because of lack liquidity the maximum amount to deposit is <span class="font-semibold">200 (a)Usdc per-transaction</span> and the minimum is <span class="font-semibold">100 (a)Usdc per-transaction</span></span>
        </div>
        <button
          class="w-full px-[1.25rem] py-[1.25rem] bg-cblack-100 rounded-xl text-white hover:brightness-50 transition-all">Send
          Stream</button>
      </div>
  </div>
</div></template>