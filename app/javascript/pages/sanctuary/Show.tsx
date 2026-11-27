import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Cottage } from "@/components/sanctuary/Cottage"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"

import type { Decoration, PageProps, SanctuaryData } from "@/types/inertia"

const DESCRIPTION =
  "Visit your cosy Nest Quest cottage, unlock new rooms as you level up, and spend the coins you earn on decorations."

const SLOT_LABELS: Record<string, string> = { rug: "Floor", plant: "Plant", lamp: "Light", wall: "Wall decoration" }

export default function SanctuaryShow() {
  const { props } = usePage<PageProps<{ sanctuary: SanctuaryData }>>()
  const { sanctuary } = props
  const coins = props.player?.coins ?? 0
  const [roomKey, setRoomKey] = useState("living_room")
  const [preview, setPreview] = useState<Decoration | null>(null)

  const room = sanctuary.rooms.find((r) => r.key === roomKey)!
  const roomName = (key: string) => sanctuary.rooms.find((r) => r.key === key)?.name ?? key
  const names = Object.fromEntries(sanctuary.items.map((i) => [i.key, i.name]))
  const placed = sanctuary.placements[roomKey] ?? {}
  const fits = (item: Decoration) => !item.rooms || item.rooms.includes(roomKey)
  const shown = preview && fits(preview) ? { ...placed, [preview.slot]: preview.key } : placed

  const post = (path: string, data: Record<string, string> = {}) =>
    router.post(path, data, { preserveScroll: true })

  const chooseRoom = (key: string) => {
    setRoomKey(key)
    setPreview(null)
  }

  return (
    <>
      <Head title="Sanctuary">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Sanctuary" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Sanctuary" description="Your cosy cottage. New rooms unlock as you level up and stay yours for good." />

        <div className="mt-6 flex flex-wrap gap-2" role="group" aria-label="Rooms">
          {sanctuary.rooms.map((r) => (
            <button
              key={r.key}
              type="button"
              className="toggle-button"
              aria-pressed={roomKey === r.key}
              disabled={!r.unlocked}
              onClick={() => chooseRoom(r.key)}
            >
              {r.name}
              {!r.unlocked && <span className="text-ink-muted"> (level {r.unlock_level})</span>}
            </button>
          ))}
        </div>
        {sanctuary.rooms.some((r) => !r.unlocked) && (
          <p className="mt-2 text-sm text-ink-muted">
            You're level {sanctuary.level}. Locked rooms open as you reach their level, and never close again.
          </p>
        )}

        <section className="mt-8 grid gap-8 lg:grid-cols-2" aria-label={room.name}>
          <div className="space-y-3">
            <Cottage placements={shown} room={roomKey} names={names} />
            {preview && (
              <div className="flex flex-wrap items-center gap-3" role="status">
                <p>
                  {fits(preview)
                    ? <>Previewing <strong>{preview.name}</strong>. Nothing is changed yet.</>
                    : <><strong>{preview.name}</strong> doesn't suit this room.</>}
                </p>
                <Button size="sm" variant="ghost" onClick={() => setPreview(null)}>Stop previewing</Button>
              </div>
            )}
            <ul className="space-y-1">
              {sanctuary.slots.map((slot) => {
                const key = placed[slot]
                return (
                  <li key={slot} className="flex flex-wrap items-center gap-2">
                    <span>{SLOT_LABELS[slot]}:</span>
                    <strong>{key ? names[key] : "Empty"}</strong>
                    {key && (
                      <Button size="sm" variant="ghost" onClick={() => post(`/sanctuary/unequip/${slot}`, { room: roomKey })}>
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
                const here = item.equipped_in === roomKey
                return (
                  <li key={item.key} className="rounded-xl border border-hairline bg-surface p-3">
                    <p><strong>{item.name}</strong></p>
                    <div className="mt-2 flex flex-wrap items-center gap-2">
                      <Badge tone="muted">{SLOT_LABELS[item.slot]}</Badge>
                      {item.rooms && <Badge tone="muted">{item.rooms.map(roomName).join(", ")} only</Badge>}
                      {item.equipped ? (
                        <Badge tone="accent">In {roomName(item.equipped_in!)}</Badge>
                      ) : item.owned ? (
                        <Badge tone="neutral">Owned</Badge>
                      ) : (
                        <Badge tone="signal">{item.price} coins</Badge>
                      )}
                    </div>
                    <div className="mt-3 flex flex-wrap gap-2">
                      {!here && (
                        <Button size="sm" variant="ghost" onClick={() => setPreview(item)} aria-pressed={preview?.key === item.key}>
                          Preview
                        </Button>
                      )}
                      {item.owned && !here && fits(item) && (
                        <Button
                          size="sm"
                          onClick={() => { setPreview(null); post(`/sanctuary/equip/${item.key}`, { room: roomKey }) }}
                        >
                          {item.equipped ? "Move here" : "Equip"}
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
