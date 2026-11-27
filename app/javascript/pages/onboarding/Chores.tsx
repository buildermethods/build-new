import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { WizardShell, type WizardInfo } from "@/components/WizardShell"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { RoomIcon } from "@/components/ui/room-icon"

import type { PageProps } from "@/types/inertia"

type ChoreRow = { key: string; title: string; minutes: number; effort: string; frequency: string; added: boolean }
type Group = { key: string; label: string; count: number; chores: ChoreRow[] }

const DESCRIPTION = "Pick the chores you want for each room. The usual housework is suggested, with sensible frequencies."

export default function Chores() {
  const { props } = usePage<PageProps<{ wizard: WizardInfo; groups: Group[]; selected: string[]; mode: string }>>()
  const { wizard, groups } = props
  const [selected, setSelected] = useState<string[]>(props.selected)
  const error = props.errors?.chores
  const base = wizard.mode === "setup" ? "/welcome" : "/add-chores"

  const toggle = (key: string) =>
    setSelected((s) => (s.includes(key) ? s.filter((k) => k !== key) : [...s, key]))

  return (
    <>
      <Head title="Your chores">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Your chores" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <WizardShell
        wizard={wizard}
        title="Which chores do you want?"
        description="We've suggested the essentials. Tick any others you'd like. You can change all of this later."
        footer={
          <Button size="lg" disabled={selected.length === 0} onClick={() => router.post(`${base}/chores`, { chores: selected })}>
            Next: how often ({selected.length} chosen)
          </Button>
        }
      >
        {error && <p className="mb-4 text-sm text-danger-display" role="alert">{error}</p>}
        <div className="space-y-8">
          {groups.map((g) => (
            <section key={g.key} aria-labelledby={`room-${g.key}`}>
              <div className="flex items-center gap-3">
                <RoomIcon room={g.key} />
                <h2 id={`room-${g.key}`}>
                  {g.label}
                  {g.count > 1 && <span className="text-ink-muted"> × {g.count}</span>}
                </h2>
              </div>
              <ul className="mt-3 space-y-2">
                {g.chores.map((c) => (
                  <li key={c.key}>
                    <label className="flex items-start gap-3 font-normal text-ink-body">
                      <Checkbox
                        className="mt-1"
                        checked={selected.includes(c.key) || c.added}
                        disabled={c.added}
                        onChange={() => toggle(c.key)}
                      />
                      <span className="flex-1">
                        {c.title}
                        <span className="block text-sm text-ink-muted">
                          about {c.minutes} min · usually {c.frequency.toLowerCase()}
                        </span>
                      </span>
                      {c.added && <Badge tone="accent">Already added</Badge>}
                    </label>
                  </li>
                ))}
              </ul>
            </section>
          ))}
        </div>
      </WizardShell>
    </>
  )
}
