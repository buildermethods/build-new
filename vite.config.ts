import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { fileURLToPath } from 'node:url'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
    RubyPlugin(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./app/frontend', import.meta.url)),
    },
  },
  // SSR bundle is built from app/javascript/entrypoints/ssr.tsx via
  // `vite build --ssr` (see package.json `build:ssr`). noExternal: true
  // bundles every dependency into the SSR output so the Node process
  // can boot without resolving anything from node_modules at runtime.
  ssr: {
    noExternal: true,
  },
})
