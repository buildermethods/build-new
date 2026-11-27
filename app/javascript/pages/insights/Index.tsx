import { Head, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"

import type { PageProps } from "@/types/inertia"

type Week = {
  label: string
  starts_on: string
  quests: number
  active_days: number
  quick_wins: number
  xp: number
  coins: number
  todos_done: number
  boss_stages: number
  top_room: string | null
  busiest_day: string | null
}

type Insights = {
  this_week: Week
  last_week: Week
  weeks: { label: string; quests: number; active_days: number }[]
  message: string
}

const DESCRIPTION = "A kind look back at your week: what you finished, how many days you showed up, and where your effort went."

function Stat({ label, value, hint }: { label: string; value: React.ReactNode; hint?: string }) {
  return (
    <div className="rounded-2xl border border-hairline bg-surface p-4">
      <p className="text-sm text-ink-muted">{label}</p>
      <p className="mt-1 text-2xl font-semibold text-ink-display">{value}</p>
      {hint && <p className="mt-1 text-sm text-ink-muted">{hint}</p>}
    </div>
  )
}

export default function InsightsPage() {
  const { props } = usePage<PageProps<{ insights: Insights }>>()
  const { this_week: w, last_week: prev, weeks, message } = props.insights
  const max = Math.max(1, ...weeks.map((x) => x.quests))

  return (
    <>
      <Head title="Insights">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Insights" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Insights" description="A gentle look at your week. No scores, no comparisons with anyone else." />

        <p className="mt-6 text-lg">{message}</p>

        <section className="mt-8" aria-label="This week">
          <h2>This week</h2>
          <div className="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <Stat label="Quests finished" value={w.quests} hint={prev.quests > 0 ? `${prev.quests} last week` : undefined} />
            <Stat label="Days active" value={`${w.active_days} of 7`} />
            <Stat label="XP earned" value={w.xp} />
            <Stat label="Quick wins" value={w.quick_wins} hint="Quests of 5 minutes or less" />
            <Stat label="To-dos ticked" value={w.todos_done} />
            <Stat label="Boss stages cleared" value={w.boss_stages} />
          </div>
          <ul className="mt-4 space-y-1">
            {w.top_room && <li>Most of your effort went into the <strong>{w.top_room}</strong>.</li>}
            {w.busiest_day && <li>Your busiest day was <strong>{w.busiest_day}</strong>.</li>}
          </ul>
        </section>

        <section className="mt-10" aria-label="Last four weeks">
          <h2>Last four weeks</h2>
          <ul className="mt-4 flex list-none items-end gap-4 p-0" aria-label="Quests finished each week">
            {weeks.map((x) => (
              <li key={x.label} className="flex flex-1 flex-col items-center gap-2">
                <div className="flex h-32 w-full items-end rounded-lg bg-surface p-1">
                  <div
                    className="w-full rounded-md bg-accent"
                    style={{ height: `${Math.max(4, Math.round((x.quests / max) * 100))}%` }}
                    role="img"
                    aria-label={`${x.label}: ${x.quests} ${x.quests === 1 ? "quest" : "quests"}, ${x.active_days} active ${x.active_days === 1 ? "day" : "days"}`}
                  />
                </div>
                <p className="text-sm font-semibold text-ink-display">{x.quests}</p>
                <p className="text-xs text-ink-muted">{x.label}</p>
              </li>
            ))}
          </ul>
        </section>
      </AppShell>
    </>
  )
}
