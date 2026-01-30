/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#1E40AF",    // Deep navy blue (main accent/buttons)
        accent: "#3B82F6",     // Lighter blue (highlights/hover)
        background: "#000000", // Pure black base
        surface: "#0F172A",    // Dark navy-gray surfaces (cards/panels)
        muted: "#64748B",      // Subtle gray text
      },
    },
  },
  plugins: [],
}
