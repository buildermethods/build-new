import { useState } from "react"
import { Head, Link, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { FocusMode } from "@/components/quest/FocusMode"
import { OneThingCard } from "@/components/quest/OneThingCard"
import { Cottage } from "@/components/sanctuary/Cottage"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"
import { MonsterArt } from "@/components/ui/monster-art"
import { ProgressRing } from "@/components/ui/progress-ring"

import type { Badge as BadgeType, Challenge, FocusTarget, PageProps, Quest, SanctuaryData } from "@/types/inertia"

const DESCRIPTION =
  "Your Nest Quest day: one clear thing to do, your progress this week, and your cottage. Small steps, no pressure."

type TodayProps = {
  greeting: string
  prompt: { kind: string; message: string; link?: { href: string; label: string } } | null
  available_count: number
  one_thing: { quest: Quest | null; energy: string; intention: { anchor: string | null } | null }
  week: { days: { label: string; date: string; active: boolean; today: boolean }[]; active_days: number; target: number; met: boolean }
  today: { wins: number; goal: number }
  identity: string
  anchors: string[]
  default_anchor: string | null
  treat: string | null
  challenges: Challenge[]
  boss: { id: number; title: string; monster_key: string; health_remaining: number; health_total: number } | null
  todos: { id: number; title: string }[]
  todo_open_count: number
  achievements: BadgeType[]
  sanctuary: SanctuaryData
}

export default function Today() {
  const { props } = usePage<PageProps<TodayProps>>()
  const { greeting, prompt, one_thing, week, today, identity, anchors, default_anchor, treat, achievements, sanctuary, todos, todo_open_count, boss, challenges } = props
  const [newTodo, setNewTodo] = useState("")
  const [excluded, setExcluded] = useState<number[]>([])
  const [focus, setFocus] = useState<FocusTarget | null>(null)
  const quest = one_thing.quest

  const go = (data: Record<string, string | number | number[]>) =>
    router.get("/", data, { preserveScroll: true, preserveState: true })

  const startFocus = (q: Quest) =>
    setFocus({ task_id: q.id, monster_key: q.monster.key, title: q.title, quest_title: q.fantasy_title, minutes: q.duration_minutes, steps: [] })

  return (
    <>
      <Head title="Today">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Today" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <h1>{greeting}</h1>

        {prompt && (
          <div className="callout callout-accent mt-4" role="status">
            <p className="text-ink-body">
              {prompt.message}
              {prompt.link && <> <Link href={prompt.link.href}>{prompt.link.label}</Link></>}
            </p>
          </div>
        )}

        <section className="mt-6 grid gap-4 sm:grid-cols-2" aria-label="Your progress">
          <div className="flex items-center gap-4 rounded-2xl border border-hairline bg-surface p-4">
            <ProgressRing
              value={today.wins}
              max={today.goal}
              center={<>{Math.min(today.wins, today.goal)}/{today.goal}</>}
              label="Today's wins"
            />
            <div>
              <h2 className="text-lg">Today's wins</h2>
              <p className="text-sm text-ink-muted">
                {today.wins >= today.goal ? "Goal reached. Anything more is a bonus." : `${today.goal - today.wins} more for a great day.`}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-4 rounded-2xl border border-hairline bg-surface p-4">
            <ProgressRing
              value={week.active_days}
              max={week.target}
              center={<>{week.active_days}/{week.target}</>}
              label="Days active this week"
            />
            <div>
              <h2 className="text-lg">This week</h2>
              <ul className="mt-1 flex list-none gap-1 p-0" aria-label="Days this week">
                {week.days.map((d) => (
                  <li
                    key={d.date}
                    title={d.label}
                    className={`flex h-6 w-6 items-center justify-center rounded-full text-[10px] ${
                      d.active ? "bg-accent text-page" : d.today ? "border border-accent text-ink-body" : "border border-hairline text-ink-muted"
                    }`}
                  >
                    <span aria-hidden="true">{d.label[0]}</span>
                    <span className="sr-only">{d.label}: {d.active ? "active" : d.today ? "today" : "quiet"}</span>
                  </li>
                ))}
              </ul>
              <p className="mt-1 text-sm text-ink-muted">{week.met ? "Weekly goal met!" : `Aim for ${week.target} days. Any pace counts.`}</p>
            </div>
          </div>
        </section>

        <p className="mt-4 italic">{identity}</p>

        <section className="mt-8" aria-label="Your one thing today">
          <h2>Your one thing today</h2>
          <div className="mt-4">
            {quest ? (
              <OneThingCard
                quest={quest}
                intentionAnchor={one_thing.intention ? one_thing.intention.anchor ?? "" : null}
                anchors={anchors}
                defaultAnchor={default_anchor}
                onStart={startFocus}
                onSwap={() => {
                  const next = [...excluded, quest.id]
                  setExcluded(next)
                  go({ exclude: next })
                }}
                onEasier={() => go({ easier: 1, exclude: excluded })}
              />
            ) : (
              <div className="rounded-2xl border border-hairline bg-surface p-5">
                <p>
                  Nothing is ready right now, and that's fine; rest counts too. You can{" "}
                  <Link href="/add-chores/rooms">add suggested chores</Link> or see the <Link href="/quests">Quest Board</Link>.
                </p>
              </div>
            )}
          </div>
          <div className="mt-4 flex flex-wrap gap-3">
            <Button asChild variant="secondary">
              <Link href="/plan">Plan my day</Link>
            </Button>
            <Button asChild variant="ghost">
              <Link href="/quests">Quest Board ({props.available_count})</Link>
            </Button>
          </div>
        </section>

        <section className="mt-10" aria-label="Challenges">
          <h2>Challenges</h2>
          <p className="mt-1 text-sm text-ink-muted">Optional extras. No timers, and nothing is lost if you skip one.</p>
          <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
            {challenges.map((c) => (
              <li key={c.key} className="rounded-2xl border border-hairline bg-surface p-4">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <h3 className="text-lg">{c.name}</h3>
                  <Badge tone="muted">{c.period === "daily" ? "Today" : "This week"}</Badge>
                </div>
                <p className="mt-1">{c.description}</p>
                <div
                  className="mt-3 h-2 overflow-hidden rounded-full bg-hairline"
                  role="progressbar"
                  aria-label={`${c.name} progress`}
                  aria-valuemin={0}
                  aria-valuemax={c.target}
                  aria-valuenow={c.current}
                >
                  <div className="h-full rounded-full bg-accent transition-all" style={{ width: `${Math.round((c.current / c.target) * 100)}%` }} />
                </div>
                <div className="mt-2 flex flex-wrap items-center justify-between gap-2">
                  <p className="text-sm text-ink-muted">{c.current} of {c.target} · +{c.xp} XP, +{c.coins} coins</p>
                  {c.claimed ? (
                    <Badge tone="accent">Claimed</Badge>
                  ) : (
                    <Button
                      size="sm"
                      disabled={!c.complete}
                      aria-label={`${c.complete ? "Claim reward" : "In progress"}: ${c.name}`}
                      onClick={() => router.post(`/challenges/${c.period}/claim`, {}, { preserveScroll: true })}
                    >
                      {c.complete ? "Claim reward" : "In progress"}
                    </Button>
                  )}
                </div>
              </li>
            ))}
          </ul>
        </section>

        {boss && (
          <section className="mt-10" aria-label="Boss battle in progress">
            <h2>Boss battle in progress</h2>
            <div className="mt-3 flex max-w-xl items-center gap-4 rounded-2xl border border-hairline bg-surface p-4">
              <MonsterArt monster={boss.monster_key} className="h-16 w-16" />
              <div className="flex-1">
                <p><strong>{boss.title}</strong></p>
                <p className="text-sm text-ink-muted">{boss.health_remaining} / {boss.health_total} HP left</p>
              </div>
              <Button asChild size="sm"><Link href={`/battles/${boss.id}`}>Continue</Link></Button>
            </div>
          </section>
        )}

        <section className="mt-10" aria-label="Quick to-dos">
          <div className="flex flex-wrap items-baseline justify-between gap-2">
            <h2>Quick to-dos</h2>
            <Link href="/todos">All to-dos{todo_open_count > 0 ? ` (${todo_open_count})` : ""}</Link>
          </div>
          {todos.length > 0 && (
            <ul className="mt-3 max-w-xl list-none divide-y divide-hairline p-0">
              {todos.map((t) => (
                <li key={t.id} className="flex items-center gap-3 py-2">
                  <Checkbox
                    id={`today-todo-${t.id}`}
                    checked={false}
                    onChange={() => router.post(`/todos/${t.id}/complete`, {}, { preserveScroll: true })}
                    aria-label={`Mark done: ${t.title}`}
                  />
                  <label htmlFor={`today-todo-${t.id}`} className="font-normal text-ink-body">{t.title}</label>
                </li>
              ))}
            </ul>
          )}
          <form
            className="mt-3 flex max-w-xl gap-2"
            onSubmit={(e) => {
              e.preventDefault()
              router.post("/todos", { title: newTodo }, { preserveScroll: true, onSuccess: () => setNewTodo("") })
            }}
          >
            <Input aria-label="Add a quick to-do" placeholder="Add a quick to-do" value={newTodo} onChange={(e) => setNewTodo(e.target.value)} />
            <Button type="submit" variant="secondary" disabled={newTodo.trim() === ""}>Add</Button>
          </form>
        </section>

        {achievements.length > 0 && (
          <section className="mt-10" aria-label="Your badges">
            <div className="flex flex-wrap items-baseline justify-between gap-2">
              <h2>Your badges</h2>
              <Link href="/achievements">See all badges</Link>
            </div>
            <ul className="mt-3 flex list-none flex-wrap gap-2 p-0">
              {achievements.map((b) => (
                <li key={b.key}>
                  <Badge tone="accent" title={b.description}>{b.name}</Badge>
                </li>
              ))}
            </ul>
          </section>
        )}

        <section className="mt-12" aria-label="Your cottage">
          <h2>Your cottage</h2>
          <div className="mt-4 grid items-center gap-6 sm:grid-cols-2">
            <Cottage
              placements={sanctuary.placements.living_room ?? {}}
              names={Object.fromEntries(sanctuary.items.map((i) => [i.key, i.name]))}
            />
            <div className="space-y-3">
              {sanctuary.teaser && (
                <p>
                  Next up: <strong>{sanctuary.teaser.name}</strong> for {sanctuary.teaser.price} coins
                  {sanctuary.teaser.coins_needed > 0
                    ? ` (${sanctuary.teaser.coins_needed} to go).`
                    : ". You can buy it now!"}
                </p>
              )}
              <Button asChild variant="secondary">
                <Link href="/sanctuary">Visit the sanctuary</Link>
              </Button>
            </div>
          </div>
        </section>

        {focus && <FocusMode target={focus} treat={treat} onClose={() => setFocus(null)} />}
      </AppShell>
    </>
  )
}
