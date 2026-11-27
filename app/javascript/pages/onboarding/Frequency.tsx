import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { WizardShell, type WizardInfo } from "@/components/WizardShell"
import { Button } from "@/components/ui/button"
import { RoomIcon } from "@/components/ui/room-icon"
import { Select } from "@/components/ui/select"

import type { PageProps } from "@/types/inertia"

type Row = { key: string; title: string; room_key: string; room_label: string; minutes: number; frequency: string }

const DESCRIPTION = "Confirm how often each chore comes round. Sensible defaults are chosen for you and every one can be changed."

export default function Frequency() {
  const { props } = usePage<
    PageProps<{ wizard: WizardInfo; chores: Row[]; frequency_options: { key: string; label: string }[]; mode: string }>
  >()
  const { wizard, chores, frequency_options } = props
  const [values, setValues] = useState<Record<string, string>>(Object.fromEntries(chores.map((c) => [c.key, c.frequency])))
  const base = wizard.mode === "setup" ? "/welcome" : "/add-chores"

  const rooms = Array.from(new Set(chores.map((c) => c.room_key)))

  return (
    <>
      <Head title="How often">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="How often" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <WizardShell
        wizard={wizard}
        title="How often should each one come round?"
        description="Wipe the sides daily, clean the oven monthly: we've picked sensible defaults. Change any you like."
        footer={
          <Button size="lg" onClick={() => router.post(`${base}/frequency`, { frequencies: values })}>
            {wizard.mode === "setup" ? "Next: almost done" : "Add these chores"}
          </Button>
        }
      >
        <div className="space-y-8">
          {rooms.map((room) => (
            <section key={room} aria-labelledby={`freq-${room}`}>
              <div className="flex items-center gap-3">
                <RoomIcon room={room} className="h-8 w-8" />
                <h2 id={`freq-${room}`}>{chores.find((c) => c.room_key === room)!.room_label}</h2>
              </div>
              <ul className="mt-3 space-y-3">
                {chores.filter((c) => c.room_key === room).map((c) => (
                  <li key={c.key} className="grid items-center gap-2 sm:grid-cols-[1fr_12rem]">
                    <label htmlFor={`f-${c.key}`} className="font-normal text-ink-body">{c.title}</label>
                    <Select id={`f-${c.key}`} value={values[c.key]} onChange={(e) => setValues((v) => ({ ...v, [c.key]: e.target.value }))}>
                      {frequency_options.map((o) => (
                        <option key={o.key} value={o.key}>{o.label}</option>
                      ))}
                    </Select>
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
