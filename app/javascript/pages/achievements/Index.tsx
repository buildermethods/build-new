import { Head, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"

import type { PageProps } from "@/types/inertia"

type BadgeProgress = {
  key: string
  name: string
  description: string
  earned: boolean
  earned_at: string | null
  current: number
  threshold: number
}

const DESCRIPTION =
  "Your Nest Quest badges: milestones you've reached and how far you are from the next ones. Badges are never taken away."

const dateText = (iso: string) => new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" })

export default function Achievements() {
  const { props } = usePage<PageProps<{ badges: BadgeProgress[]; earned_count: number }>>()
  const { badges, earned_count } = props
  const earned = badges.filter((b) => b.earned)
  const next = badges.filter((b) => !b.earned)

  return (
    <>
      <Head title="Badges">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Badges" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader
          title="Badges"
          description={`${earned_count} of ${badges.length} earned. Milestones only: no timers, no chance, nothing you can lose.`}
        />

        <section className="mt-8" aria-label="Earned badges">
          <h2>Earned</h2>
          {earned.length === 0 ? (
            <p className="mt-2">None yet. Finish your first quest to earn First Victory.</p>
          ) : (
            <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
              {earned.map((b) => (
                <li key={b.key} className="rounded-xl border border-accent bg-accent-faded p-4">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <h3>{b.name}</h3>
                    <Badge tone="accent">Earned</Badge>
                  </div>
                  <p className="mt-1">{b.description}</p>
                  {b.earned_at && <p className="mt-1 text-sm text-ink-muted">Earned {dateText(b.earned_at)}</p>}
                </li>
              ))}
            </ul>
          )}
        </section>

        {next.length > 0 && (
          <section className="mt-12" aria-label="Badges to earn">
            <h2>Next to earn</h2>
            <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
              {next.map((b) => {
                const percent = Math.round((b.current / b.threshold) * 100)
                return (
                  <li key={b.key} className="rounded-xl border border-hairline bg-surface p-4">
                    <h3>{b.name}</h3>
                    <p className="mt-1">{b.description}</p>
                    <div
                      className="mt-3 h-2 overflow-hidden rounded-full bg-hairline"
                      role="progressbar"
                      aria-label={`${b.name} progress`}
                      aria-valuemin={0}
                      aria-valuemax={b.threshold}
                      aria-valuenow={b.current}
                    >
                      <div className="h-full rounded-full bg-accent transition-all" style={{ width: `${percent}%` }} />
                    </div>
                    <p className="mt-1 text-sm text-ink-muted">{b.current} of {b.threshold}</p>
                  </li>
                )
              })}
            </ul>
          </section>
        )}
      </AppShell>
    </>
  )
}
