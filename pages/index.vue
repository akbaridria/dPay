<script setup lang="ts">
// import and component
import { reactive } from 'vue';
import benefits from '../datas/benefits.json';
import flows from '../datas/flows.json';

useHead({
  title: 'dPay | Home'
})
// interfaces
import { Benefits, StreamingFlow } from '../interfaces/globalInterfaces';

// props and datas
const benefit = reactive<Benefits[]>(benefits.benefits);
const streamflow = reactive<StreamingFlow[]>(flows.flows);

// computed and watcher

// methods

// lifecycle

</script>

<template>
  <div>
    <section class="relative bg-black h-screen max-h-[900px]">
      <img class="absolute top-0 right-0 h-full" src="/images/looper-33.svg" alt="">
      <div class="relative max-w-[1030px] mx-auto h-full">
        <div class="flex items-center justify-center text-white h-full">
          <div class="text-center text-[40px] sm:text-[3.75rem] font-medium">
            <div>Effortlessly cross-chain stream</div>
            <div>continuous cryptocurrency payments</div>
          </div>
        </div>
      </div>
    </section>
    <section class="h-fit py-[6rem] lg:max-h-[900px] bg-cwhite-100 grid items-center">
      <div class="max-w-[1030px] p-4 mx-auto w-full">
        <div class="grid gap-[3rem]">
          <div class="grid lg:grid-cols-3">
            <div class="text-[2rem]">
              <div class="font-bold text-cblack-300">DAOs World.</div>
              <div class="text-cblue-100 font-bold">Stream solution</div>
            </div>
            <div class="col-span-2 text-[1.2rem] text-cblack-300">
              Dpay represents a cross-chain protocol enabling the automation and real-time streaming of transactions.
              Beneficiaries have the flexibility to withdraw these funds whenever and whatever chain they desired, eliminating the necessity for
              manual repetitive payment processes.
            </div>
          </div>
          <div class="grid lg:grid-cols-3 gap-[1rem]">
            <div v-for="(item, index) in benefit" :key="index" class="relative h-[400px] p-3 rounded-lg bg-white">
              <div class="flex flex-col gap-2 h-full justify-end relative z-[2]">
                <div class="text-[1.5rem] font-semibold">{{ item.title }}</div>
                <div class="h-[105px] text-[1rem] text-black/50">{{ item.subtitle }}</div>
              </div>
              <img :src="`images/${item.image}`" class="absolute top-0 left-0 w-full h-full z-[1]" alt="">
            </div>
          </div>
        </div>
      </div>
    </section>
    <section class="h-[700px] max-h-[900px] bg-black">
      <div class="relative z-[2] max-w-[1030px] p-4 mx-auto w-full h-full grid items-center">
        <div class="reative z-[2] text-[30px] sm:text-[3.75rem] text-white text-center font-medium">How it works</div>
        <div class="relative z-[10] grid gap-2">
          <div v-for="(item, index ) in streamflow" :key="index" class="grid grid-cols-3">
            <div v-for="index2 in 3" :key="index2" class="text-white max-w-[200px]">
              <div class="text-[2.2rem] mb-[1rem]">{{ index2-1 === index ? item.number : '' }}</div>
              <div class="text-[1.25rem] font-medium">{{ index2-1 === index ? item.title  : '' }}</div>
              <div class="text-[1rem] text-white/50">{{ index2-1 === index ? item.description : '' }}</div>
            </div>
          </div>
        </div>
        <img class="absolute top-0 left-0 w-full h-full" src="/images/looper-benefit-1.svg" alt="">
      </div>
    </section>        
    <section class="h-fit py-[6rem] lg:max-h-[900px] bg-cwhite-100 grid items-center">
      <div class="max-w-[1030px] p-4 mx-auto w-full">
        <div class="relative grid md:grid-cols-2 bg-black rounded-xl p-[3.75rem]">
          <div class="grid gap-3 text-white">
            <div class="text-[2rem] font-medium">Stream seamless recurring crypto payments!</div>
            <div class="text-[1rem] text-white/50">Automate salaries by streaming them - so employees can withdraw whenever and whatever chain they want.</div>
            <a href="#" class="my-[1rem] bg-cblack-200 px-[2rem] py-[1rem] rounded-lg w-fit">Stream now</a>
          </div>
          <IconsBanner class="absolute top-0 right-0 h-full hidden md:block" />
        </div>
      </div>
    </section>
  </div>
</template>