import { createInertiaApp } from '@inertiajs/react'
import createServer from '@inertiajs/react/server'
import { createElement, ReactNode } from 'react'
import ReactDOMServer from 'react-dom/server'

type ResolvedComponent = {
  default: ReactNode
  layout?: (page: ReactNode) => ReactNode
}

createServer((page) =>
  createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    resolve: (name) => {
      const pages = import.meta.glob<ResolvedComponent>('../pages/**/*.tsx', {
        eager: true,
      })
      return pages[`../pages/${name}.tsx`]
    },
    setup: ({ App, props }) => createElement(App, props),
  }),
)
