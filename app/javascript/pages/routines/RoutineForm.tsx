import { FormEvent } from "react"
import { useForm } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"
import { Select } from "@/components/ui/select"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"

import type { Routine } from "@/types/inertia"

const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

type StepDraft = { id?: number; title: string; task_id: string }
type FormData = { name: string; weekdays: number[]; steps: StepDraft[] }

const fromRoutine = (r: Routine | null): FormData =>
  r
    ? {
        name: r.name,
        weekdays: r.weekdays,
        steps: r.steps.map((s) => ({ id: s.id, title: s.title, task_id: s.task_id ? String(s.task_id) : "" })),
      }
    : { name: "", weekdays: [], steps: [{ title: "", task_id: "" }] }

export function RoutineForm({
  routine,
  taskOptions,
  onOpenChange,
}: {
  routine: Routine | null
  taskOptions: { id: number; title: string }[]
  onOpenChange: (open: boolean) => void
}) {
  const form = useForm<FormData>(fromRoutine(routine))
  const { data, setData, errors } = form

  const submit = (e: FormEvent) => {
    e.preventDefault()
    const opts = { preserveScroll: true, onSuccess: () => onOpenChange(false) }
    if (routine) form.patch(`/routines/${routine.id}`, opts)
    else form.post("/routines", opts)
  }

  const setStep = (index: number, patch: Partial<StepDraft>) =>
    setData("steps", data.steps.map((s, i) => (i === index ? { ...s, ...patch } : s)))

  const move = (index: number, delta: number) => {
    const target = index + delta
    if (target < 0 || target >= data.steps.length) return
    const next = [...data.steps]
    ;[next[index], next[target]] = [next[target], next[index]]
    setData("steps", next)
  }

  const toggleDay = (day: number) =>
    setData("weekdays", data.weekdays.includes(day) ? data.weekdays.filter((d) => d !== day) : [...data.weekdays, day])

  const errorText = (key: string) => (errors as Record<string, string | undefined>)[key]

  return (
    <Dialog open onOpenChange={onOpenChange}>
      <DialogContent size="lg">
        <form onSubmit={submit} className="space-y-4">
          <DialogHeader>
            <DialogTitle>{routine ? "Edit routine" : "New routine"}</DialogTitle>
            <DialogDescription>An ordered list of steps that repeats on the days you choose.</DialogDescription>
          </DialogHeader>

          <div className="space-y-2">
            <label htmlFor="routine-name">Name</label>
            <Input
              id="routine-name"
              value={data.name}
              placeholder="School morning launch"
              aria-invalid={!!errors.name}
              onChange={(e) => setData("name", e.target.value)}
            />
            {errorText("name") && <p className="text-xs text-danger-display">{errorText("name")}</p>}
          </div>

          <fieldset className="space-y-2">
            <legend>Days (leave empty for every day)</legend>
            <div className="flex flex-wrap gap-3">
              {WEEKDAYS.map((name, day) => (
                <label key={name} className="flex items-center gap-2 font-normal text-ink-body">
                  <Checkbox checked={data.weekdays.includes(day)} onChange={() => toggleDay(day)} />
                  {name}
                </label>
              ))}
            </div>
          </fieldset>

          <fieldset className="space-y-3">
            <legend>Steps</legend>
            {data.steps.map((step, i) => (
              <div key={step.id ?? `new-${i}`} className="flex flex-wrap items-start gap-2">
                <div className="min-w-0 flex-1 space-y-2">
                  <Input
                    aria-label={`Step ${i + 1} title`}
                    value={step.title}
                    placeholder="Pack bags"
                    onChange={(e) => setStep(i, { title: e.target.value })}
                  />
                  <Select
                    aria-label={`Step ${i + 1} linked task`}
                    value={step.task_id}
                    onChange={(e) => setStep(i, { task_id: e.target.value })}
                  >
                    <option value="">No linked task</option>
                    {taskOptions.map((t) => (
                      <option key={t.id} value={t.id}>{t.title}</option>
                    ))}
                  </Select>
                </div>
                <div className="flex gap-1">
                  <Button type="button" size="sm" variant="ghost" onClick={() => move(i, -1)} aria-label={`Move step ${i + 1} up`}>Up</Button>
                  <Button type="button" size="sm" variant="ghost" onClick={() => move(i, 1)} aria-label={`Move step ${i + 1} down`}>Down</Button>
                  <Button
                    type="button"
                    size="sm"
                    variant="ghost"
                    aria-label={`Remove step ${i + 1}`}
                    onClick={() => setData("steps", data.steps.filter((_, idx) => idx !== i))}
                  >
                    Remove
                  </Button>
                </div>
              </div>
            ))}
            <Button type="button" size="sm" variant="secondary" onClick={() => setData("steps", [...data.steps, { title: "", task_id: "" }])}>
              Add step
            </Button>
          </fieldset>

          <DialogFooter>
            <Button type="button" variant="ghost" onClick={() => onOpenChange(false)}>Cancel</Button>
            <Button type="submit" disabled={form.processing}>{routine ? "Save" : "Create routine"}</Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
