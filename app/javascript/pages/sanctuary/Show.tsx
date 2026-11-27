import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Cottage } from "@/components/sanctuary/Cottage"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"

import type { Decoration, PageProps, SanctuaryData } from "@/types/inertia"

const DESCRIPTION =
  "Visit your cosy Nest Quest cottage, spend the coins you earn on decorations and see your home grow brighter with every chore you finish."

const SLOT_LABELS: Record<string, string> = { rug: "Rug", plant: "Plant", lamp: "Lamp", wall: "Wall decoration" }

export default function SanctuaryShow() {
  const { props } = usePage<PageProps<{ sanctuary: SanctuaryData }>>()
  const { sanctuary } = props
  const coins = props.player?.coins ?? 0
  const [preview, setPreview] = useState<Decoration | null>(null)

  const names = Object.fromEntries(sanctuary.items.map((i) => [i.key, i.name]))
  const shown = preview ? { ...sanctuary.placements, [preview.slot]: preview.key } : sanctuary.placements

  const post = (path: string) => router.post(path, {}, { preserveScroll: true })

  return (
    <>
      <Head title="Sanctuary">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Sanctuary" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Sanctuary" description="Your cosy cottage. Coins from finished quests buy decorations." />

        {props.flash?.alert && <p className="mt-4 text-sm text-danger-display" role="alert">{props.flash.alert}</p>}

        <section className="mt-8 grid gap-8 lg:grid-cols-2" aria-label="Cottage">
          <div className="space-y-3">
            <Cottage placements={shown} names={names} />
            {preview && (
              <div className="flex flex-wrap items-center gap-3" role="status">
                <p>Previewing <strong>{preview.name}</strong>. Nothing is changed yet.</p>
                <Button size="sm" variant="ghost" onClick={() => setPreview(null)}>Stop previewing</Button>
              </div>
            )}
            <ul className="space-y-1">
              {sanctuary.slots.map((slot) => {
                const key = sanctuary.placements[slot]
                return (
                  <li key={slot} className="flex flex-wrap items-center gap-2">
                    <span>{SLOT_LABELS[slot]}:</span>
                    <strong>{key ? names[key] : "Empty"}</strong>
                    {key && (
                      <Button size="sm" variant="ghost" onClick={() => post(`/sanctuary/unequip/${slot}`)}>
                        Remove
                      </Button>
                    )}
                  </li>
                )
              })}
            </ul>
          </div>

          <div>
            <h2>Decoration shop</h2>
            <p className="mt-1">You have <strong>{coins}</strong> coins.</p>
            <ul className="mt-4 grid list-none gap-3 p-0 sm:grid-cols-2">
              {sanctuary.items.map((item) => {
                const short = item.price - coins
                return (
                  <li key={item.key} className="rounded-xl border border-hairline bg-surface p-3">
                    <p><strong>{item.name}</strong></p>
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      <Badge tone="muted">{SLOT_LABELS[item.slot]}</Badge>
                      {item.equipped ? (
                        <Badge tone="accent">Equipped</Badge>
                      ) : item.owned ? (
                        <Badge tone="neutral">Owned</Badge>
                      ) : (
                        <Badge tone="signal">{item.price} coins</Badge>
                      )}
                    </div>
                    <div className="mt-3 flex flex-wrap gap-2">
                      {!item.equipped && (
                        <Button size="sm" variant="ghost" onClick={() => setPreview(item)} aria-pressed={preview?.key === item.key}>
                          Preview
                        </Button>
                      )}
                      {item.owned && !item.equipped && (
                        <Button size="sm" onClick={() => { setPreview(null); post(`/sanctuary/equip/${item.key}`) }}>
                          Equip
                        </Button>
                      )}
                      {!item.owned && (
                        <Button
                          size="sm"
                          variant="secondary"
                          disabled={short > 0}
                          onClick={() => post(`/sanctuary/purchase/${item.key}`)}
                        >
                          {short > 0 ? `Need ${short} more` : "Buy"}
                        </Button>
                      )}
                    </div>
                  </li>
                )
              })}
            </ul>
          </div>
        </section>
      </AppShell>
    </>
  )
}
