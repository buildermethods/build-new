import * as React from "react"
import { usePage } from "@inertiajs/react"
import { MainNav } from "@/components/MainNav"
import { VictoryDialog } from "@/components/VictoryDialog"
import { XpBar } from "@/components/ui/xp-bar"

import type { PageProps } from "@/types/inertia"

export function AppShell({ children }: { children: React.ReactNode }) {
  const { props } = usePage<PageProps>()
  const player = props.player

  return (
    <div className="flex min-h-screen bg-page text-ink-body">
      <MainNav />
      <main className="min-w-0 flex-1 px-6 py-8 sm:px-10">
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
