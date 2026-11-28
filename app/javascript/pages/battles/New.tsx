import { useState } from "react"
import { Head, Link, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { MonsterArt } from "@/components/ui/monster-art"
import { Select } from "@/components/ui/select"
import { Checkbox } from "@/components/ui/checkbox"
import { RewardsPanel, type Rewards } from "./Index"

import type { PageProps } from "@/types/inertia"

type Chore = { id: number; title: string; room: string; minutes: number }
type Template = { key: string; name: string; title: string; monster_key: string; stages: string[] }

const DESCRIPTION = "Start a boss battle: choose a template or write your own stages for a big job."

export default function NewBattle() {
  const { props } = usePage<
    PageProps<{
      templates: Template[]
      monsters: { key: string; name: string }[]
      limits: { min: number; max: number }
      chores: Chore[]
      rewards: Rewards
    }>
  >()
  const { templates, monsters, limits, chores, rewards } = props
  const first = templates[0]
  const [title, setTitle] = useState(first.title)
  const [monster, setMonster] = useState(first.monster_key)
  const [stages, setStages] = useState<string[]>(first.stages)
  const [picked, setPicked] = useState(first.key)
  const [taskIds, setTaskIds] = useState<number[]>([])
  const errors = props.errors ?? {}
  const free = stages.filter((s) => s.trim() !== "")
  const total = Math.min(limits.max, taskIds.length + free.length)
  const room = limits.max - free.length
  const payout = rewards.defeat_xp + rewards.stack_bonus_xp * total
  const toggleChore = (id: number) =>
    setTaskIds((ids) => (ids.includes(id) ? ids.filter((x) => x !== id) : ids.length < room ? [...ids, id] : ids))

  const choose = (t: Template) => {
    setPicked(t.key)
    setTitle(t.title)
    setMonster(t.monster_key)
    setStages(t.stages)
  }

  const setStage = (i: number, value: string) => setStages((s) => s.map((x, idx) => (idx === i ? value : x)))

  return (
    <>
      <Head title="New boss battle">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="New boss battle" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="New boss battle" description="Split a big job into small stages. Start from a template or write your own." />

        <div className="mt-6 max-w-xl">
          <RewardsPanel rewards={rewards} />
        </div>

        <section className="mt-8" aria-label="Templates">
          <h2>Start from a template</h2>
          <div className="mt-3 flex flex-wrap gap-2" role="group" aria-label="Templates">
            {templates.map((t) => (
              <button key={t.key} type="button" className="toggle-button" aria-pressed={picked === t.key} onClick={() => choose(t)}>
                {t.name}
              </button>
            ))}
          </div>
        </section>

        <form
          className="mt-8 max-w-xl space-y-6"
          onSubmit={(e) => {
            e.preventDefault()
            router.post("/battles", { title, monster_key: monster, stages, task_ids: taskIds })
          }}
        >
          <div className="flex items-center gap-4">
            <MonsterArt monster={monster} className="h-20 w-20" />
            <div className="flex-1 space-y-2">
              <label htmlFor="battle-title">Battle name</label>
              <Input id="battle-title" value={title} maxLength={120} aria-invalid={!!errors.title} onChange={(e) => setTitle(e.target.value)} />
            </div>
          </div>

          <div className="space-y-2">
            <label htmlFor="battle-monster">Boss</label>
            <Select id="battle-monster" value={monster} onChange={(e) => setMonster(e.target.value)}>
              {monsters.map((m) => <option key={m.key} value={m.key}>{m.name}</option>)}
            </Select>
          </div>

          {chores.length > 0 && (
            <fieldset className="space-y-2">
              <legend>Stack your real chores ({taskIds.length} chosen)</legend>
              <p className="caption">Each chore you tick becomes a stage, and it clears itself when you complete the chore.</p>
              <ul className="max-h-64 space-y-2 overflow-y-auto">
                {chores.map((c) => (
                  <li key={c.id}>
                    <label className="flex items-start gap-3 font-normal text-ink-body">
                      <Checkbox
                        className="mt-1"
                        checked={taskIds.includes(c.id)}
                        disabled={!taskIds.includes(c.id) && taskIds.length >= room}
                        onChange={() => toggleChore(c.id)}
                      />
                      <span className="flex-1">
                        {c.title}
                        <span className="block caption">{c.room} · about {c.minutes} min</span>
                      </span>
                    </label>
                  </li>
                ))}
              </ul>
            </fieldset>
          )}

          <fieldset className="space-y-3">
            <legend>Other stages ({free.length}; {limits.min} to {limits.max} in total)</legend>
            {stages.map((s, i) => (
              <div key={i} className="flex items-center gap-2">
                <Input aria-label={`Stage ${i + 1}`} value={s} maxLength={160} onChange={(e) => setStage(i, e.target.value)} />
                <Button
                  type="button"
                  size="sm"
                  variant="ghost"
                  aria-label={`Remove stage ${i + 1}`}
                  onClick={() => setStages((x) => x.filter((_, idx) => idx !== i))}
                >
                  Remove
                </Button>
              </div>
            ))}
            <Button
              type="button"
              size="sm"
              variant="secondary"
              disabled={taskIds.length + stages.length >= limits.max}
              onClick={() => setStages((x) => [...x, ""])}
            >
              Add stage
            </Button>
            {errors.base && <p className="text-sm text-danger-display" role="alert">{errors.base}</p>}
          </fieldset>

          <p aria-live="polite">
            <strong>{total} {total === 1 ? "stage" : "stages"}</strong>: clear them all to earn <strong>{payout} XP and {rewards.defeat_coins} coins</strong>, plus {rewards.stage_xp} XP per stage.
          </p>

          <div className="flex gap-3">
            <Button asChild variant="ghost"><Link href="/battles">Cancel</Link></Button>
            <Button type="submit" size="lg">Start the battle</Button>
          </div>
        </form>
      </AppShell>
    </>
  )
}
