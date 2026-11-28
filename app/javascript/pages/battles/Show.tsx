import { useState } from "react"
import { Head, Link, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { MonsterArt } from "@/components/ui/monster-art"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { HealthBar, RewardsPanel, type BattleSummary, type Rewards } from "./Index"

import type { PageProps } from "@/types/inertia"

type Stage = { id: number; title: string; damage: number; done: boolean; linked: boolean }
type Battle = BattleSummary & { stages: Stage[]; rewards: Rewards; photos: { before: string | null; after: string | null } }

const DESCRIPTION = "Work through the stages of your boss battle. Progress is saved, so leave and come back any time."


function PhotoSlot({ battleId, slot, url, live }: { battleId: number; slot: "before" | "after"; url: string | null; live: boolean }) {
  const label = slot === "before" ? "Before" : "After"
  const upload = (file: File | undefined) => {
    if (!file) return
    router.post(`/battles/${battleId}/photos/${slot}`, { photo: file }, { forceFormData: true, preserveScroll: true })
  }
  return (
    <div className="flex-1 space-y-2">
      <h3 className="heading-sm">{label}</h3>
      {url ? (
        <>
          <img src={url} alt={`${label} photo of the space`} className="aspect-[4/3] w-full rounded-xl border border-hairline object-cover" />
          <Button size="sm" variant="ghost" aria-label={`Remove ${label.toLowerCase()} photo`} onClick={() => router.delete(`/battles/${battleId}/photos/${slot}`, { preserveScroll: true })}>
            Remove
          </Button>
        </>
      ) : live || slot === "after" ? (
        <>
          <label htmlFor={`photo-${slot}`} className="caption">Add a {label.toLowerCase()} photo (JPG, PNG or WebP, up to 5 MB)</label>
          <input id={`photo-${slot}`} type="file" accept="image/jpeg,image/png,image/webp" onChange={(e) => upload(e.target.files?.[0])} />
        </>
      ) : (
        <p className="caption">No photo.</p>
      )}
    </div>
  )
}

export default function ShowBattle() {
  const { props } = usePage<PageProps<{ battle: Battle }>>()
  const { battle } = props
  const [confirm, setConfirm] = useState(false)
  const live = battle.status === "active"

  const toggle = (s: Stage) =>
    router.post(`/battles/${battle.id}/stages/${s.id}/${s.done ? "uncomplete" : "complete"}`, {}, { preserveScroll: true })

  return (
    <>
      <Head title={battle.title}>
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content={battle.title} />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title={battle.title} description={`${battle.monster} · ${battle.stages_done} of ${battle.stages_total} stages cleared`} />

        <section className="mt-6 flex max-w-xl items-center gap-5" aria-label="Boss health">
          <MonsterArt monster={battle.monster_key} className="h-24 w-24" />
          <div className="flex-1">
            <HealthBar remaining={battle.health_remaining} total={battle.health_total} label={`${battle.title} health`} />
            {battle.status === "defeated" && <Badge tone="accent">Defeated</Badge>}
            {battle.status === "abandoned" && <Badge tone="muted">Set aside</Badge>}
          </div>
        </section>

        {live && (
          <div className="mt-6 max-w-xl">
            <RewardsPanel rewards={battle.rewards} stages={battle.stages_total} />
          </div>
        )}

        <section className="mt-8 max-w-xl" aria-label="Stages">
          <h2>Stages</h2>
          <ol className="mt-3 divide-y divide-hairline">
            {battle.stages.map((s, i) => (
              <li key={s.id} className="flex items-start gap-3 py-3">
                {s.linked ? (
                  <>
                    <Checkbox id={`stage-${s.id}`} className="mt-1" checked={s.done} disabled readOnly />
                    <label htmlFor={`stage-${s.id}`} className={`flex-1 font-normal ${s.done ? "text-ink-muted line-through" : "text-ink-body"}`}>
                      <span className="text-ink-muted">Stage {i + 1}. </span>{s.title}
                      {!s.done && live && (
                        <span className="block caption">
                          Your chore: it clears when you complete it on the <Link href="/quests">Quest Board</Link>.
                        </span>
                      )}
                    </label>
                    <Badge tone="accent">Chore</Badge>
                  </>
                ) : (
                  <>
                    <Checkbox id={`stage-${s.id}`} className="mt-1" checked={s.done} disabled={!live} onChange={() => toggle(s)} />
                    <label htmlFor={`stage-${s.id}`} className={`flex-1 font-normal ${s.done ? "text-ink-muted line-through" : "text-ink-body"}`}>
                      <span className="text-ink-muted">Stage {i + 1}. </span>{s.title}
                    </label>
                  </>
                )}
                <Badge tone="muted">-{s.damage} HP</Badge>
              </li>
            ))}
          </ol>
        </section>

        <section className="mt-8 max-w-xl" aria-label="Before and after">
          <h2>Before and after</h2>
          <p className="caption mt-1">Optional. Photos are private: only you can see them.</p>
          <div className="mt-3 flex flex-wrap gap-4">
            <PhotoSlot battleId={battle.id} slot="before" url={battle.photos.before} live={live} />
            <PhotoSlot battleId={battle.id} slot="after" url={battle.photos.after} live={live} />
          </div>
        </section>

        <div className="mt-8 flex flex-wrap gap-3">
          <Button asChild variant="secondary"><Link href="/battles">{live ? "Leave for later" : "Back to battles"}</Link></Button>
          {live && <Button variant="ghost" onClick={() => setConfirm(true)}>Set this battle aside</Button>}
        </div>

        <Dialog open={confirm} onOpenChange={setConfirm}>
          <DialogContent size="sm">
            <DialogHeader>
              <DialogTitle>Set this battle aside?</DialogTitle>
              <DialogDescription>Nothing is lost. You can always start it again as a new battle.</DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="ghost" onClick={() => setConfirm(false)}>Keep going</Button>
              <Button onClick={() => router.post(`/battles/${battle.id}/abandon`)}>Set aside</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </AppShell>
    </>
  )
}
