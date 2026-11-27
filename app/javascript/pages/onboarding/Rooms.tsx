import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { WizardShell, type WizardInfo } from "@/components/WizardShell"
import { Button } from "@/components/ui/button"
import { RoomIcon } from "@/components/ui/room-icon"

import type { PageProps } from "@/types/inertia"

type RoomDef = { key: string; label: string; max_count: number; always: boolean }

const DESCRIPTION = "Choose the rooms in your home so Nest Quest can suggest the right chores for each one."

export default function Rooms() {
  const { props } = usePage<PageProps<{ wizard: WizardInfo; rooms: RoomDef[]; counts: Record<string, number> }>>()
  const { wizard, rooms } = props
  const [counts, setCounts] = useState<Record<string, number>>(props.counts)
  const error = props.errors?.rooms

  const set = (key: string, n: number) => setCounts((c) => ({ ...c, [key]: n }))
  const selectable = rooms.filter((r) => !r.always)
  const base = wizard.mode === "setup" ? "/welcome" : "/add-chores"

  return (
    <>
      <Head title="Your rooms">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Your rooms" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <WizardShell
        wizard={wizard}
        title="Which rooms do you have?"
        description="Tick each room. For bedrooms and bathrooms, say how many, and we'll make chores for each one."
        footer={
          <Button size="lg" onClick={() => router.post(`${base}/rooms`, { rooms: counts })}>
            Next: choose chores
          </Button>
        }
      >
        {error && <p className="mb-4 text-sm text-danger-display" role="alert">{error}</p>}
        <ul className="grid list-none gap-3 p-0 sm:grid-cols-2">
          {selectable.map((room) => {
            const n = counts[room.key] ?? 0
            const on = n > 0
            return (
              <li
                key={room.key}
                className={`rounded-xl border p-4 ${on ? "border-accent bg-accent-faded" : "border-hairline bg-surface"}`}
              >
                <div className="flex items-center gap-3">
                  <RoomIcon room={room.key} />
                  <div className="flex-1">
                    <p><strong>{room.label}</strong></p>
                    {on && room.max_count > 1 && <p className="text-sm text-ink-muted">{n} {n === 1 ? "room" : "rooms"}</p>}
                  </div>
                </div>
                <div className="mt-3 flex flex-wrap items-center gap-2">
                  <button
                    type="button"
                    className="toggle-button"
                    aria-pressed={on}
                    onClick={() => set(room.key, on ? 0 : 1)}
                  >
                    {on ? "Included" : "Include"}
                  </button>
                  {on && room.max_count > 1 && (
                    <>
                      <Button
                        size="sm"
                        variant="secondary"
                        aria-label={`Fewer ${room.label} rooms`}
                        disabled={n <= 1}
                        onClick={() => set(room.key, n - 1)}
                      >
                        −
                      </Button>
                      <Button
                        size="sm"
                        variant="secondary"
                        aria-label={`More ${room.label} rooms`}
                        disabled={n >= room.max_count}
                        onClick={() => set(room.key, n + 1)}
                      >
                        +
                      </Button>
                    </>
                  )}
                </div>
              </li>
            )
          })}
        </ul>
        <p className="mt-4 text-sm text-ink-muted">Whole-home chores (like meal planning) are always included.</p>
      </WizardShell>
    </>
  )
}
