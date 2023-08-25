<script setup lang="ts">
// import and component
import datas from '../protocol-contract/datas/chains.json';

// interfaces

// data and props
const open = ref(false);

// computed and watcher

// methods

// lifecycle
</script>

<template>
  <div class="sticky top-0 bg-black z-[100]">
    <div class="container mx-auto p-4">
      <div class="flex justify-between">
        <div><LogosDPayLogos class="w-[56px] h-[56px] fill-white" /></div>
        <div class="flex items-center gap-2">
          <div class="dropdown">
            <label 
              tabindex="0" 
              class="flex gap-1 items-center bg-cblack-100 text-white px-[1.25rem] py-[1rem] rounded-xl hover:brightness-150 transition-all"
              @click="open = true"
              @click-outside="open = false"
            >
              <div>Select Network</div>
              <IconsChevron 
                class="w-[24px] h-[24px] fill-white rotate-[90deg]" 
                :class="{'rotate-[270deg]': open}"
              />
            </label>
            <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box mt-[0.5rem] w-52">
              <li v-for="(item, index) in datas" :key="index">
                <a>
                  <component :is="item.logo" class="w-[24px] h-[24px]" />
                  {{ item.detail.chainName }}
                </a>
              </li>
            </ul>
          </div>
          <button class="bg-cblack-200 px-[1.25rem] py-[1rem] rounded-xl hover:brightness-150 transition-all flex items-center gap-2 text-white">
            <LogosMetamask class="w-[18px] h-[18px]" />
            <div>Connect Metamask</div>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>