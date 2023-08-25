<script setup lang="ts">

</script>

<template>
  <div class="w-full mt-[5rem] bg-white rounded-xl p-4">
    <div class="tabs">
      <a class="tab tab-lg tab-lifted">Large</a>
      <a class="tab tab-lg tab-lifted tab-active">Large</a>
      <a class="tab tab-lg tab-lifted">Large</a>
    </div>
    <div class="overflow-x-auto">
      <table class="table text-[1rem] mt-[2rem]">
        <!-- head -->
        <thead>
          <tr>
            <th></th>
            <th>Name</th>
            <th>Job</th>
            <th>Favorite Color</th>
          </tr>
        </thead>
        <tbody>
          <!-- row 1 -->
          <tr>
            <th>1</th>
            <td>Cy Ganderton</td>
            <td>Quality Control Specialist</td>
            <td>Blue</td>
          </tr>
          <!-- row 2 -->
          <tr>
            <th>2</th>
            <td>Hart Hagerty</td>
            <td>Desktop Support Technician</td>
            <td>Purple</td>
          </tr>
          <!-- row 3 -->
          <tr>
            <th>3</th>
            <td>Brice Swyre</td>
            <td>Tax Accountant</td>
            <td>Red</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>