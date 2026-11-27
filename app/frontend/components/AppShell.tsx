import * as React from "react"
import { usePage } from "@inertiajs/react"
import { MainNav } from "@/components/MainNav"
import { VictoryDialog } from "@/components/VictoryDialog"
import { XpBar } from "@/components/ui/xp-bar"

import type { PageProps } from "@/types/inertia"

export function AppShell({ children }: { children: React.ReactNode }) {
  const { props } = usePage<PageProps>()
  const player = props.player
  const reducedMotion = props.current_user?.reduced_motion ?? false

  // The server renders this class on full page loads; keep it in sync after
  // in-app navigation (e.g. saving the setting) too.
  React.useEffect(() => {
    document.documentElement.classList.toggle("reduce-motion", reducedMotion)
  }, [reducedMotion])

  return (
    <div className="flex min-h-screen bg-page text-ink-body">
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-md focus:bg-surface focus:px-4 focus:py-2"
      >
        Skip to content
      </a>
      <MainNav />
      <main id="main" tabIndex={-1} className="min-w-0 flex-1 px-6 py-8 focus:outline-none sm:px-10">
        <div className="mx-auto max-w-4xl">
          {player && (
            <XpBar
              className="mb-6"
              level={player.level}
              xpIntoLevel={player.xp_into_level}
              xpForNextLevel={player.xp_for_next_level}
              coins={player.coins}
            />
          )}
          {children}
        </div>
      </main>
      <VictoryDialog />
    </div>
  )
}
