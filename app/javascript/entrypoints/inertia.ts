import { createInertiaApp } from '@inertiajs/react'
import { createElement, type ReactNode } from 'react'
import { createRoot } from 'react-dom/client'
import { ErrorBoundary } from '@/components/ErrorBoundary'
import { installStandaloneRecovery } from '@/lib/standalone-recovery'

type ResolvedComponent = {
  default: ReactNode
  layout?: (page: ReactNode) => ReactNode
}

// Recover iOS Home Screen (standalone PWA) sessions from a dead/suspended
// WebKit context. Client-only — never imported by the SSR entrypoint.
installStandaloneRecovery()

createInertiaApp({
  resolve: (name) => {
    const pages = import.meta.glob<ResolvedComponent>('../pages/**/*.tsx', {
      eager: true,
    })
    const page = pages[`../pages/${name}.tsx`]
    if (!page) {
      console.error(`Missing Inertia page component: '${name}.tsx'`)
    }
    return page
  },

  setup({ el, App, props }) {
    if (el) {
      createRoot(el).render(
        createElement(ErrorBoundary, null, createElement(App, props)),
      )
    } else {
      console.error(
        'Missing root element. Move `vite_typescript_tag "inertia"` into an Inertia-specific layout.',
      )
    }
  },
})
