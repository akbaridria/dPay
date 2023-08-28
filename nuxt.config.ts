// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@pinia/nuxt',
  ],
  css: ['~/assets/css/main.css'],
  postcss: {
    plugins: {
      tailwindcss: {},
      autoprefixer: {},
    },
  },
  components: {
    dirs: [
      {
        path: '~/components/icons', prefix: 'Icons', global: true,
      },
      {
        path: '~/components/logos', prefix: 'Logos', global: true
      },
      {
        path: '~/components/Modals', prefix: 'Modals', global: true
      },
      {
        path: '~/components'
      }
    ]
  }
})
