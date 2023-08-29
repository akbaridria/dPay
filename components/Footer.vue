<script setup lang="ts">
// import and component
import menus from '../datas/menus.json';

// interfaces
import { Menus } from '../interfaces/globalInterfaces';

// props and data
const dataMenu = reactive<Menus[]>(menus.menus);
const route = useRoute();

// computed and watcher

// methods

// lifecycle

</script>

<template>
  <div id="footer" class="bg-black p-[2rem]">
    <div class="max-w-[1030px] mx-auto">
      <div class="grid md:grid-cols-2 gap-4">
        <div class="grid gap-2">
          <div class="flex gap-4">
            <NuxtLink 
              v-for="(item, index) in dataMenu" :key="index"
              :href="item.link" 
              :target="item.newTab ? '_blank' : ''"
              class="text-white/50 text-[1rem] font-medium hover:text-white transition-all"
              :class="{'!text-white': route.path === item.link}"
            >
              {{ item.name }}
            </NuxtLink>
          </div>
          <div class="text-white/50">
            Media inquires for Dpay Labs - Contact: <a class="underline" href="mailto:akbaridria15@gmail.com">akbaridria15@gmail.com</a>
          </div>
        </div>
        <div class="flex gap-4 items-center md:justify-end">
          <a href="https://github.com/akbaridria/dPay" target="_blank" class="bg-cblack-200 rounded-full p-2">
            <IconsGithub class="w-[31px] h-[31px] fill-white/50 hover:fill-white" />
          </a>
          <div class="bg-cblack-200 rounded-full p-2">
            <IconsDiscord class="w-[31px] h-[31px] fill-white/50" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>