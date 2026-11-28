import { Head, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"
import { MonsterArt } from "@/components/ui/monster-art"

import type { PageProps } from "@/types/inertia"

type Entry = {
  key: string
  name: string
  discovered: boolean
  description: string
  flavor: string
  defeats: number
  first_defeated_on: string | null
}

const DESCRIPTION = "Your Monster Codex: every chore monster you've met, how many times you've defeated it, and when you first did."

const dateText = (iso: string) => new Date(`${iso}T00:00:00`).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" })

export default function Codex() {
  const { props } = usePage<PageProps<{ monsters: Entry[]; discovered: number; total: number }>>()
  const { monsters, discovered, total } = props

  return (
    <>
      <Head title="Monster Codex">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Monster Codex" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader
          title="Monster Codex"
          description={`${discovered} of ${total} discovered. Defeat a monster for the first time to add it here.`}
        />
        <ul className="mt-8 grid list-none gap-4 p-0 sm:grid-cols-2">
          {monsters.map((m) => (
            <li key={m.key} className="rounded-2xl border border-hairline bg-surface p-4">
              <div className="flex items-center gap-4">
                <div aria-hidden={!m.discovered}>
                  <MonsterArt
                    monster={m.key}
                    className={`h-20 w-20 ${m.discovered ? "" : "opacity-25 brightness-0"}`}
                  />
                </div>
                <div className="flex-1">
                  <h3>{m.discovered ? m.name : "Undiscovered monster"}</h3>
                  {m.discovered ? (
                    <Badge tone="accent">Defeated {m.defeats} {m.defeats === 1 ? "time" : "times"}</Badge>
                  ) : (
                    <Badge tone="muted">Not met yet</Badge>
                  )}
                </div>
              </div>
              {m.discovered ? (
                <>
                  <p className="mt-3">{m.description}</p>
                  <p className="mt-1 italic caption">{m.flavor}</p>
                  {m.first_defeated_on && (
                    <p className="mt-2 caption">First defeated {dateText(m.first_defeated_on)}</p>
                  )}
                </>
              ) : (
                <p className="mt-3 caption">Finish a quest in its part of the home to meet this one.</p>
              )}
            </li>
          ))}
        </ul>
      </AppShell>
    </>
  )
}
