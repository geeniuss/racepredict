/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_FACTORY_ADDRESS: `0x${string}`
  // Add other env vars here later if needed
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
