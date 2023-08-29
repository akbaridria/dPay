<script setup lang="ts">
// import and component

// interfaces
interface props {
  question: string,
  answer: string
}

// data and props
const open = ref<boolean>(false)
const props = defineProps<props>()

// computed and watcher

// methods

// lifecycle

</script>

<template>
  <div>
    <div class="flex justify-between items-center cursor-pointer" @click="open = !open">
      <div class="text-base sm:text-[1.5rem] font-medium">
        {{ $props.question }}
      </div>
      <IconsChevron 
        class="w-[24px] h-[24px] fill-black rotate-[90deg] transition-all" 
        :class="{'!rotate-[270deg]': open}"
      />
    </div>
    <div v-if="open" class="py-[1rem] text-sm sm:text-[1rem] w-[90%]">
      {{ $props.answer }}
    </div>
  </div>
</template>