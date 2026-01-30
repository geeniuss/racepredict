/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#FF8C00",   // Orange pill vibe 🍊
        accent: "#DC2626",    // F1 red
        background: "#000000",
        surface: "#1F1F1F",
      },
    },
  },
  plugins: [],
}
