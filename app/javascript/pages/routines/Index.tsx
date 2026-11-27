import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { EmptyState } from "@/components/ui/empty-state"
import { RoutineForm } from "./RoutineForm"

import type { PageProps, Routine } from "@/types/inertia"

const DESCRIPTION =
  "Build repeatable Nest Quest routines from ordered steps, like the school morning launch or the Sunday reset, and track today's progress."

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

const schedule = (r: Routine) => (r.weekdays.length === 0 ? "Every day" : r.weekdays.map((d) => DAYS[d]).join(", "))

function RoutineCard({ routine, onEdit }: { routine: Routine; onEdit: (r: Routine) => void }) {
  const complete = routine.total > 0 && routine.done_count === routine.total
  const toggle = (stepId: number, done: boolean) =>
    done
      ? router.delete(`/routines/${routine.id}/steps/${stepId}/uncomplete`, { preserveScroll: true })
      : router.post(`/routines/${routine.id}/steps/${stepId}/complete`, {}, { preserveScroll: true })

  return (
    <article className="rounded-xl border border-hairline bg-surface p-4" aria-label={routine.name}>
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h3>{routine.name}</h3>
        <Badge tone={complete ? "accent" : "muted"}>
          {complete ? "Done for today" : `${routine.done_count} of ${routine.total} done`}
        </Badge>
      </div>
      <p className="mt-1 text-sm text-ink-muted">{schedule(routine)}</p>
      <ul className="mt-3 space-y-2">
        {routine.steps.map((s) => (
          <li key={s.id} className="flex items-center gap-3">
            <Checkbox
              id={`step-${s.id}`}
              checked={s.done_today}
              onChange={() => toggle(s.id, s.done_today)}
            />
            <label htmlFor={`step-${s.id}`} className={`font-normal ${s.done_today ? "text-ink-muted line-through" : "text-ink-body"}`}>
              {s.title}
            </label>
          </li>
        ))}
      </ul>
      <div className="mt-4 flex flex-wrap gap-2">
        {routine.scheduled_today && !complete && routine.total > 0 && (
          <Button size="sm" onClick={() => router.post(`/routines/${routine.id}/complete_all`, {}, { preserveScroll: true })}>
            Complete all
          </Button>
        )}
        <Button size="sm" variant="ghost" onClick={() => onEdit(routine)} aria-label={`Edit ${routine.name}`}>Edit</Button>
        <Button
          size="sm"
          variant="ghost"
          aria-label={`Delete ${routine.name}`}
          onClick={() => router.delete(`/routines/${routine.id}`, { preserveScroll: true })}
        >
          Delete
        </Button>
      </div>
    </article>
  )
}

export default function RoutinesIndex() {
  const { props } = usePage<PageProps<{ routines: Routine[]; task_options: { id: number; title: string }[] }>>()
  const { routines, task_options } = props
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<Routine | null>(null)

  const today = routines.filter((r) => r.scheduled_today)
  const later = routines.filter((r) => !r.scheduled_today)
  const open = (r: Routine | null) => {
    setEditing(r)
    setFormOpen(true)
  }

  return (
    <>
      <Head title="Routines">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Routines" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader
          title="Routines"
          description="Repeatable sequences of steps. Tick them one by one, or all at once."
          actions={<Button onClick={() => open(null)}>New routine</Button>}
        />

        <section className="mt-8" aria-label="Today's routines">
          <h2>Today</h2>
          {today.length === 0 ? (
            routines.length === 0 ? (
              <EmptyState
                className="mt-3"
                monster="backpack_bandits"
                title="No routines yet"
                action={<Button onClick={() => open(null)}>Create my first routine</Button>}
              >
                A routine is an ordered list of steps, like the school morning launch.
              </EmptyState>
            ) : (
              <p className="mt-2">No routines are scheduled for today.</p>
            )
          ) : (
            <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
              {today.map((r) => (
                <li key={r.id}><RoutineCard routine={r} onEdit={open} /></li>
              ))}
            </ul>
          )}
        </section>

        {later.length > 0 && (
          <section className="mt-12" aria-label="Other routines">
            <h2>Other days</h2>
            <ul className="mt-4 grid list-none gap-4 p-0 sm:grid-cols-2">
              {later.map((r) => (
                <li key={r.id}><RoutineCard routine={r} onEdit={open} /></li>
              ))}
            </ul>
          </section>
        )}

        {formOpen && (
          <RoutineForm key={editing?.id ?? "new"} routine={editing} taskOptions={task_options} onOpenChange={setFormOpen} />
        )}
      </AppShell>
    </>
  )
}
