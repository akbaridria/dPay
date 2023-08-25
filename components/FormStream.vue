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
        <button class="w-full btn bg-cblue-100 rounded-xl text-white hover:bg-cblue-100 hover:brightness-75">Send
          Stream</button>
      </div>
    </div>
  </div>
</template>