import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { QuestCard } from "@/components/ui/quest-card"
import { TaskForm } from "./TaskForm"

import type { PageProps, Quest, QuestHistoryItem, QuestOptions } from "@/types/inertia"

const DESCRIPTION =
  "Your household tasks as Nest Quest quests. Filter by room, time and difficulty, then complete, skip or postpone each one without penalty."

const humanize = (value: string) => {
  const text = value.replace(/_/g, " ")
  return text.charAt(0).toUpperCase() + text.slice(1)
}

const TIME_FILTERS = [
  { value: "any", label: "Any time" },
  { value: "5", label: "Up to 5 min" },
  { value: "15", label: "Up to 15 min" },
]

const DIFFICULTY_FILTERS = ["All", "Easy", "Medium", "Hard", "Boss"]

function Chips({
  label,
  options,
  value,
  onChange,
}: {
  label: string
  options: { value: string; label: string }[]
  value: string
  onChange: (value: string) => void
}) {
  return (
    <div className="flex flex-wrap items-center gap-1.5" role="group" aria-label={label}>
      {options.map((o) => (
        <button
          key={o.value}
          type="button"
          className="toggle-button"
          aria-pressed={value === o.value}
          onClick={() => onChange(o.value)}
        >
          {o.label}
        </button>
      ))}
    </div>
  )
}

function recurrenceText(q: Quest) {
  if (q.recurrence_kind === "calendar") {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    return `Repeats ${q.recurrence_weekdays.map((d) => days[d]).join(", ")}`
  }
  if (q.recurrence_kind === "completion") return `Repeats ${q.recurrence_interval_days} days after done`
  return undefined
}

function formatDate(iso: string) {
  return new Date(`${iso}T00:00:00`).toLocaleDateString(undefined, { month: "short", day: "numeric" })
}

export default function QuestsIndex() {
  const { props } = usePage<
    PageProps<{ quests: Quest[]; upcoming: Quest[]; history: QuestHistoryItem[]; options: QuestOptions }>
  >()
  const { quests, upcoming, history, options } = props

  const [room, setRoom] = useState("all")
  const [time, setTime] = useState("any")
  const [difficulty, setDifficulty] = useState("All")
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<Quest | null>(null)

  const visible = quests.filter(
    (q) =>
      (room === "all" || q.room === room) &&
      (time === "any" || q.duration_minutes <= Number(time)) &&
      (difficulty === "All" || q.difficulty === difficulty),
  )

  const post = (path: string, data: Record<string, string | number> = {}) =>
    router.post(path, data, { preserveScroll: true })

  const openForm = (quest: Quest | null) => {
    setEditing(quest)
    setFormOpen(true)
  }

  const actions = (q: Quest) => (
    <>
      {q.available && (
        <Button size="sm" aria-label={`Complete ${q.title}`} onClick={() => post(`/tasks/${q.id}/complete`)}>
          Complete
        </Button>
      )}
      {q.available && (
        <Button size="sm" variant="secondary" aria-label={`Skip ${q.title}`} onClick={() => post(`/tasks/${q.id}/skip`)}>
          Skip
        </Button>
      )}
      {q.available && (
        <Button size="sm" variant="secondary" aria-label={`Postpone ${q.title} until tomorrow`} onClick={() => post(`/tasks/${q.id}/defer`, { days: 1 })}>
          Tomorrow
        </Button>
      )}
      <Button size="sm" variant="ghost" aria-label={`Edit ${q.title}`} onClick={() => openForm(q)}>
        Edit
      </Button>
      <Button
        size="sm"
        variant="ghost"
        aria-label={`Remove ${q.title}`}
        onClick={() => router.delete(`/tasks/${q.id}`, { preserveScroll: true })}
      >
        Remove
      </Button>
    </>
  )

  const statusFor = (q: Quest) => {
    if (!q.available) {
      const back = q.deferred_until ?? q.next_due_on
      return back ? `Back ${formatDate(back)}` : undefined
    }
    return recurrenceText(q)
  }

  return (
    <>
      <Head title="Quest Board">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Quest Board" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader
          title="Quest Board"
          description="Your chores, as quests. Skip or postpone any of them with no penalty."
          actions={<Button onClick={() => openForm(null)}>Add quest</Button>}
        />

        <section className="mt-8 space-y-3" aria-label="Filters">
          <Chips
            label="Filter by room"
            value={room}
            onChange={setRoom}
            options={[{ value: "all", label: "All rooms" }, ...options.rooms.map((r) => ({ value: r, label: humanize(r) }))]}
          />
          <Chips label="Filter by time" value={time} onChange={setTime} options={TIME_FILTERS} />
          <Chips
            label="Filter by difficulty"
            value={difficulty}
            onChange={setDifficulty}
            options={DIFFICULTY_FILTERS.map((d) => ({ value: d, label: d }))}
          />
        </section>

        <section className="mt-8" aria-label="Available quests">
          {visible.length === 0 ? (
            <p>
              {quests.length === 0
                ? "No quests are waiting. Add your first one to begin."
                : "No quests match these filters."}
            </p>
          ) : (
            <ul className="grid list-none gap-4 p-0 sm:grid-cols-2">
              {visible.map((q) => (
                <li key={q.id}>
                  <QuestCard
                    fantasyTitle={q.fantasy_title}
                    title={q.title}
                    monsterName={q.monster.name}
                    minutes={q.duration_minutes}
                    difficulty={q.difficulty}
                    xp={q.xp}
                    coins={q.coins}
                    status={statusFor(q)}
                    actions={actions(q)}
                  />
                </li>
              ))}
            </ul>
          )}
        </section>

        {upcoming.length > 0 && (
          <section className="mt-12" aria-label="Coming up">
            <h2>Coming up</h2>
            <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
              {upcoming.map((q) => (
                <li key={q.id}>
                  <QuestCard
                    fantasyTitle={q.fantasy_title}
                    title={q.title}
                    monsterName={q.monster.name}
                    minutes={q.duration_minutes}
                    difficulty={q.difficulty}
                    xp={q.xp}
                    coins={q.coins}
                    status={statusFor(q)}
                    actions={actions(q)}
                  />
                </li>
              ))}
            </ul>
          </section>
        )}

        <section className="mt-12" aria-label="Recently completed">
          <h2>Recently completed</h2>
          {history.length === 0 ? (
            <p className="mt-2">Nothing finished yet. Your first victory is waiting.</p>
          ) : (
            <ul className="mt-4 divide-y divide-hairline list-none p-0">
              {history.map((h) => (
                <li key={h.id} className="flex flex-wrap items-center gap-3 py-3">
                  <p className="flex-1">
                    {h.title}{" "}
                    <span className="text-ink-muted">
                      ({new Date(h.completed_at).toLocaleDateString(undefined, { month: "short", day: "numeric" })})
                    </span>
                  </p>
                  <Button size="sm" variant="ghost" aria-label={`Undo ${h.title}`} onClick={() => post(`/tasks/${h.task_id}/uncomplete`)}>
                    Undo
                  </Button>
                </li>
              ))}
            </ul>
          )}
        </section>

        {formOpen && (
          <TaskForm
            key={editing?.id ?? "new"}
            open={formOpen}
            onOpenChange={setFormOpen}
            quest={editing}
            options={options}
          />
        )}
      </AppShell>
    </>
  )
}
