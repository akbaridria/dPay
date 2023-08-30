// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  ssr: false,
  nitro: {
    prerender: {
      crawlLinks: true,
      failOnError: false, 
    },
  },
  modules: [
    '@pinia/nuxt',
  ],
  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: 'images/dpay-logo.svg' }
      ],
    }
  },
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
  },
  typescript: {
    tsConfig: {
      compilerOptions: {
        target: 'es2020',
      },
    }
  },
  
})
