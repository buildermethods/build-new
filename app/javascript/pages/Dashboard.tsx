import { useState } from "react"
import { Head, Link, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { FocusMode } from "@/components/quest/FocusMode"
import { PlanView } from "@/components/quest/PlanView"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { QuestCard } from "@/components/ui/quest-card"

import type { EnergyMode, FocusTarget, PageProps, Quest, QuestPlan } from "@/types/inertia"

const DESCRIPTION =
  "Tell Nest Quest how much time and energy you have and get a realistic quest plan from your own tasks, or let it pick one thing for you."

type DashboardProps = {
  greeting: string
  available_count: number
  energy_modes: EnergyMode[]
  time_options: number[]
  checkin: { minutes: number; energy: string; context: string }
  suggestions: Quest[]
  plan: QuestPlan | null
  single: { quest: Quest | null; energy: string } | null
}

export default function Dashboard() {
  const { props } = usePage<PageProps<DashboardProps>>()
  const { greeting, available_count, energy_modes, time_options, suggestions, plan, single } = props

  const [minutes, setMinutes] = useState(props.checkin.minutes)
  const [energy, setEnergy] = useState(props.checkin.energy)
  const [context, setContext] = useState(props.checkin.context)
  const [excluded, setExcluded] = useState<number[]>([])
  const [focus, setFocus] = useState<FocusTarget | null>(null)

  const go = (data: Record<string, string | number | number[]>) =>
    router.get("/", data, { preserveScroll: true, preserveState: true })

  const planQuests = () => go({ minutes, energy, context, plan: 1 })
  const justTell = (extra: Record<string, string | number | number[]> = {}, ex = excluded) =>
    go({ minutes, energy, just: 1, ...(ex.length ? { exclude: ex } : {}), ...extra })

  const startFocus = (q: Quest) =>
    setFocus({ task_id: q.id, title: q.title, quest_title: q.fantasy_title, minutes: q.duration_minutes, steps: [] })

  const selectedMode = energy_modes.find((m) => m.key === energy)

  return (
    <>
      <Head title="Home">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Home" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <h1>{greeting}</h1>
        <p className="mt-1">
          {available_count === 0
            ? "No quests are waiting. Add a task on the Quest Board to begin."
            : `${available_count} ${available_count === 1 ? "quest is" : "quests are"} ready for you.`}
        </p>

        <section className="mt-8 space-y-6" aria-label="Check in">
          <div className="space-y-2">
            <h2>How much time do you have?</h2>
            <div className="flex flex-wrap gap-1.5" role="group" aria-label="Available time">
              {time_options.map((m) => (
                <button
                  key={m}
                  type="button"
                  className="toggle-button"
                  aria-pressed={minutes === m}
                  onClick={() => setMinutes(m)}
                >
                  {m} min
                </button>
              ))}
            </div>
          </div>

          <div className="space-y-2">
            <h2>How is your energy?</h2>
            <div className="flex flex-wrap gap-1.5" role="group" aria-label="Energy level">
              {energy_modes.map((m) => (
                <button
                  key={m.key}
                  type="button"
                  className="toggle-button"
                  aria-pressed={energy === m.key}
                  onClick={() => setEnergy(m.key)}
                >
                  {m.label}
                </button>
              ))}
            </div>
            {selectedMode && <p className="text-sm text-ink-muted">{selectedMode.description}</p>}
          </div>

          <div className="max-w-xl space-y-2">
            <label htmlFor="checkin-context">Anything else going on? (optional)</label>
            <Input
              id="checkin-context"
              value={context}
              maxLength={300}
              placeholder="My back hurts and the kitchen looks awful"
              onChange={(e) => setContext(e.target.value)}
            />
          </div>

          <div className="flex flex-wrap gap-3">
            <Button size="lg" onClick={() => { setExcluded([]); justTell({}, []) }}>
              Just tell me what to do
            </Button>
            <Button size="lg" variant="secondary" onClick={planQuests}>
              Plan my quests
            </Button>
          </div>
        </section>

        <div className="mt-10" aria-live="polite">
          {single && (
            <section aria-label="Your next quest" className="space-y-3">
              <h2>Your next quest</h2>
              {single.quest ? (
                <>
                  <QuestCard
                    fantasyTitle={single.quest.fantasy_title}
                    title={single.quest.title}
                    monsterName={single.quest.monster.name}
                    minutes={single.quest.duration_minutes}
                    difficulty={single.quest.difficulty}
                    xp={single.quest.xp}
                    coins={single.quest.coins}
                    actions={
                      <>
                        <Button size="sm" onClick={() => startFocus(single.quest!)}>Start</Button>
                        <Button
                          size="sm"
                          variant="secondary"
                          onClick={() => {
                            const next = [...excluded, single.quest!.id]
                            setExcluded(next)
                            justTell({}, next)
                          }}
                        >
                          Swap
                        </Button>
                        <Button
                          size="sm"
                          variant="secondary"
                          onClick={() => router.post(`/tasks/${single.quest!.id}/defer`, { days: 1 }, { preserveScroll: true })}
                        >
                          Later
                        </Button>
                        <Button size="sm" variant="ghost" onClick={() => justTell({ easier: 1 })}>
                          Something easier
                        </Button>
                      </>
                    }
                  />
                </>
              ) : (
                <p>
                  Nothing is ready to suggest right now. That's fine; rest counts too. You can add tasks on the{" "}
                  <Link href="/quests">Quest Board</Link>.
                </p>
              )}
            </section>
          )}

          {plan && <PlanView plan={plan} onStart={setFocus} />}

          {!plan && !single && suggestions.length > 0 && (
            <section aria-label="Suggested quests" className="space-y-3">
              <h2>Suggested quests</h2>
              <ul className="grid list-none gap-4 p-0 sm:grid-cols-2">
                {suggestions.map((q) => (
                  <li key={q.id}>
                    <QuestCard
                      fantasyTitle={q.fantasy_title}
                      title={q.title}
                      monsterName={q.monster.name}
                      minutes={q.duration_minutes}
                      difficulty={q.difficulty}
                      xp={q.xp}
                      coins={q.coins}
                      actions={
                        <>
                          <Button size="sm" onClick={() => router.post(`/tasks/${q.id}/complete`, {}, { preserveScroll: true })}>
                            Complete
                          </Button>
                          <Button size="sm" variant="secondary" onClick={() => startFocus(q)}>Focus</Button>
                        </>
                      }
                    />
                  </li>
                ))}
              </ul>
            </section>
          )}
        </div>

        {focus && <FocusMode target={focus} onClose={() => setFocus(null)} />}
      </AppShell>
    </>
  )
}
