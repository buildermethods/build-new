import { Head, Link, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { EmptyState } from "@/components/ui/empty-state"
import { MonsterArt } from "@/components/ui/monster-art"

import type { PageProps } from "@/types/inertia"

export type BattleSummary = {
  id: number
  title: string
  monster_key: string
  monster: string
  status: string
  health_remaining: number
  health_total: number
  stages_done: number
  stages_total: number
  defeated_at: string | null
}

const DESCRIPTION = "Big jobs as boss battles: split a daunting task into stages, clear them one at a time, and come back whenever you like."

export function HealthBar({ remaining, total, label }: { remaining: number; total: number; label: string }) {
  const percent = Math.round((remaining / total) * 100)
  return (
    <div>
      <div
        className="h-3 overflow-hidden rounded-full bg-hairline"
        role="progressbar"
        aria-label={label}
        aria-valuemin={0}
        aria-valuemax={total}
        aria-valuenow={remaining}
      >
        <div className="h-full rounded-full bg-danger transition-all" style={{ width: `${percent}%` }} />
      </div>
      <p className="mt-1 caption">{remaining} / {total} HP</p>
    </div>
  )
}

export type Rewards = { stage_xp: number; defeat_xp: number; defeat_coins: number; stack_bonus_xp: number }

// Spells out what a battle pays so the stakes are never a surprise.
export function RewardsPanel({ rewards, stages }: { rewards: Rewards; stages?: number }) {
  return (
    <section className="rounded-xl border border-hairline bg-accent-faded p-4" aria-label="How rewards work">
      <h2 className="heading-sm">How a boss battle pays</h2>
      <ul className="mt-2 space-y-1">
        <li>Each stage you clear: <strong>+{rewards.stage_xp} XP</strong></li>
        <li>
          Clear every stage and the boss falls: <strong>+{rewards.defeat_xp} XP and +{rewards.defeat_coins} coins</strong>
          {stages === undefined ? ` (more with every stage you add: +${rewards.stack_bonus_xp} XP each)` : ""}
        </li>
        <li>Stack your real chores as stages: finishing a chore anywhere clears its stage for you.</li>
      </ul>
      <p className="caption mt-2">Nothing is ever taken away, and you can leave a battle and come back any time.</p>
    </section>
  )
}

function BattleCard({ b }: { b: BattleSummary }) {
  return (
    <article className="rounded-2xl border border-hairline bg-surface p-4">
      <div className="flex items-center gap-4">
        <MonsterArt monster={b.monster_key} className="h-16 w-16" />
        <div className="flex-1">
          <p className="caption">{b.monster}</p>
          <h3>{b.title}</h3>
        </div>
        {b.status === "defeated" && <Badge tone="accent">Defeated</Badge>}
      </div>
      <div className="mt-3">
        <HealthBar remaining={b.health_remaining} total={b.health_total} label={`${b.title} health`} />
        <p className="mt-1 caption">{b.stages_done} of {b.stages_total} stages cleared</p>
      </div>
      <Button asChild size="sm" variant={b.status === "defeated" ? "ghost" : "primary"} className="mt-3">
        <Link href={`/battles/${b.id}`}>{b.status === "defeated" ? "View" : "Continue"}</Link>
      </Button>
    </article>
  )
}

export default function BattlesIndex() {
  const { props } = usePage<PageProps<{ active: BattleSummary[]; defeated: BattleSummary[]; abandoned_count: number; rewards: Rewards }>>()
  const { active, defeated } = props

  return (
    <>
      <Head title="Boss battles">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Boss battles" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader
          title="Boss battles"
          description="Big jobs, one stage at a time. Leave and come back whenever you like."
          actions={<Button asChild><Link href="/battles/new">New boss battle</Link></Button>}
        />

        <div className="mt-6 max-w-xl">
          <RewardsPanel rewards={props.rewards} />
        </div>

        <section className="mt-8" aria-label="Active battles">
          <h2>In progress</h2>
          {active.length === 0 ? (
            <EmptyState
              className="mt-3"
              monster="doom_pile_dragon"
              title="No battle underway"
              action={<Button asChild><Link href="/battles/new">Start a boss battle</Link></Button>}
            >
              Pick a daunting job and split it into stages.
            </EmptyState>
          ) : (
            <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
              {active.map((b) => <li key={b.id}><BattleCard b={b} /></li>)}
            </ul>
          )}
        </section>

        {defeated.length > 0 && (
          <section className="mt-12" aria-label="Defeated bosses">
            <h2>Defeated</h2>
            <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
              {defeated.map((b) => <li key={b.id}><BattleCard b={b} /></li>)}
            </ul>
          </section>
        )}
      </AppShell>
    </>
  )
}
