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

  const [removed, setRemoved] = useState<string[]>([])
  const visible = groups.filter((g) => !removed.includes(g.key))
  const choosable = (g: Group) => g.chores.filter((c) => !c.added).map((c) => c.key)
  const allKeys = visible.flatMap(choosable)
  const chosen = selected.filter((k) => allKeys.includes(k))
  const allChosen = allKeys.length > 0 && chosen.length === allKeys.length
  const roomAllChosen = (g: Group) => choosable(g).every((k) => selected.includes(k))
  const setRoom = (g: Group, on: boolean) =>
    setSelected((s) => [...s.filter((k) => !choosable(g).includes(k)), ...(on ? choosable(g) : [])])
  const removeRoom = (g: Group) => {
    setRemoved((r) => [...r, g.key])
    setSelected((s) => s.filter((k) => !choosable(g).includes(k)))
  }

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
        description="We've suggested the essentials. Tick any others, or select them all. Every chore you choose is ready to do today, and you can change all of this later."
        footer={
          <Button size="lg" disabled={chosen.length === 0} onClick={() => router.post(`${base}/chores`, { chores: chosen })}>
            Next: how often ({chosen.length} chosen)
          </Button>
        }
      >
        {error && <p className="mb-4 text-sm text-danger-display" role="alert">{error}</p>}
        <div className="mb-6 flex flex-wrap items-center gap-2">
          <Button size="sm" variant="secondary" onClick={() => setSelected(allChosen ? [] : allKeys)}>
            {allChosen ? "Clear all chores" : "Select all chores"}
          </Button>
          <p className="caption" aria-live="polite">{chosen.length} of {allKeys.length} chosen</p>
        </div>
        <div className="space-y-8">
          {visible.map((g) => (
            <section key={g.key} aria-labelledby={`room-${g.key}`}>
              <div className="flex flex-wrap items-center gap-3">
                <RoomIcon room={g.key} />
                <h2 id={`room-${g.key}`} className="flex-1">
                  {g.label}
                  {g.count > 1 && <span className="text-ink-muted"> × {g.count}</span>}
                </h2>
                <button type="button" className="toggle-button" onClick={() => setRoom(g, !roomAllChosen(g))}>
                  {roomAllChosen(g) ? `Clear ${g.label}` : `Select all ${g.label}`}
                </button>
                <button type="button" className="toggle-button" onClick={() => removeRoom(g)}>
                  Remove {g.label}
                </button>
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
