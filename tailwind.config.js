/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./nuxt.config.{js,ts}",
    "./app.vue",
  ],
  theme: {
    extend: {
      colors: {
        cblue: {
          100: '#5B45FF'
        },
        cblack: {
          100: '#111',
          200: '#1F1F1F',
          300: '#131313'
        },
        cwhite: {
          100: '#F3F3F3'
        }
      },
    },
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: false,
    darkTheme: "light",
  }
}

