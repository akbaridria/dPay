<script setup lang="ts">
// import and component
import datas from '../datas/menus.json'

// interfaces
import { Menus } from '../interfaces/globalInterfaces'

// props and datas
const menus = reactive<Menus[]>(datas.menus);
const isExpand = ref(false);
const router = useRoute();

// computed and watcher

// methods

// lifecycle
</script>

<template>
  <div class="relative container mx-auto">
    <div class="relative z-10">
      <div class="absolute top-[calc(100vh/2-130px)] left-0">
        <div class="fixed">
          <div class="grid gap-2 p-2 bg-cblack-100 rounded-lg text-white">
            <a 
              v-for="(item, index) in menus" 
              class="group flex gap-2 p-4 hover:bg-cblack-200 hover:rounded-lg transition-all"
              :class="{'bg-cblack-200 rounded-lg': router.path === item.link}"
              :href="item.link" 
              :key="index"
            >
              <component 
                :is="item.icon" 
                class="w-[24px] h-[24px] stroke-white/50 group-hover:stroke-white transition-all" 
                :class="{'!stroke-white': router.path === item.link}"
              />
              <div 
                v-if="isExpand" 
                class="text-white/50 group-hover:text-white"
                :class="{'!text-white': router.path === item.link}"
              >
                {{ item.name }}
              </div>
            </a>
            <div 
              class="group bg-cblack-100 p-2 rounded-full ring-4 ring-black absolute top-[calc(50%-1.5rem)] right-[-1.5rem] cursor-pointer"
              @click="isExpand = !isExpand"
            >
              <IconsChevron 
                class="w-[24px] h-[24px] fill-white/50 group-hover:fill-white transition-all" 
                :class="{'rotate-[180deg]': isExpand}"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>