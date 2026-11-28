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

import type { Quest, QuestOptions } from "@/types/inertia"

const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

const humanize = (value: string) => {
  const text = value.replace(/_/g, " ")
  return text.charAt(0).toUpperCase() + text.slice(1)
}

const RECURRENCE_LABELS: Record<string, string> = {
  none: "Does not repeat",
  calendar: "Repeats on set days of the week",
  completion: "Repeats some days after I finish it",
}

type FormData = {
  title: string
  notes: string
  room: string
  category: string
  duration_minutes: number
  effort: string
  priority: string
  due_on: string
  recurrence_kind: string
  recurrence_interval_days: number
  recurrence_weekdays: number[]
  assignee_id: string
  rotate: boolean
}

const blank: FormData = {
  title: "",
  notes: "",
  room: "other",
  category: "other",
  duration_minutes: 10,
  effort: "small",
  priority: "normal",
  due_on: "",
  recurrence_kind: "none",
  recurrence_interval_days: 7,
  recurrence_weekdays: [],
  assignee_id: "",
  rotate: false,
}

function fromQuest(q: Quest): FormData {
  return {
    title: q.title,
    notes: q.notes ?? "",
    room: q.room,
    category: q.category,
    duration_minutes: q.duration_minutes,
    effort: q.effort,
    priority: q.priority,
    due_on: q.due_on ?? "",
    recurrence_kind: q.recurrence_kind,
    recurrence_interval_days: q.recurrence_interval_days ?? 7,
    recurrence_weekdays: q.recurrence_weekdays,
    assignee_id: q.assignee_id ? String(q.assignee_id) : "",
    rotate: q.rotate,
  }
}

export function TaskForm({
  open,
  onOpenChange,
  quest,
  options,
  members = [],
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  quest: Quest | null
  options: QuestOptions
  members?: { id: number; name: string }[]
}) {
  const form = useForm<FormData>(quest ? fromQuest(quest) : blank)
  const { data, setData, errors } = form

  const submit = (e: FormEvent) => {
    e.preventDefault()
    const done = { preserveScroll: true, onSuccess: () => onOpenChange(false) }
    if (quest) form.patch(`/tasks/${quest.id}`, done)
    else form.post("/tasks", { ...done, onSuccess: () => { form.reset(); onOpenChange(false) } })
  }

  const toggleDay = (day: number) =>
    setData(
      "recurrence_weekdays",
      data.recurrence_weekdays.includes(day)
        ? data.recurrence_weekdays.filter((d) => d !== day)
        : [...data.recurrence_weekdays, day],
    )

  const error = (key: string) =>
    (errors as Record<string, string | undefined>)[key] && (
      <p className="text-xs text-danger-display">{(errors as Record<string, string>)[key]}</p>
    )

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent size="lg">
        <form onSubmit={submit} className="space-y-4">
          <DialogHeader>
            <DialogTitle>{quest ? "Edit quest" : "Add a quest"}</DialogTitle>
            <DialogDescription>
              Describe the real task in plain words. We'll add the monster.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-2">
            <label htmlFor="task-title">Task</label>
            <Input
              id="task-title"
              value={data.title}
              aria-invalid={!!errors.title}
              onChange={(e) => setData("title", e.target.value)}
              placeholder="Wipe kitchen countertops"
            />
            {error("title")}
          </div>

          <div className="space-y-2">
            <label htmlFor="task-notes">Notes (optional)</label>
            <Input id="task-notes" value={data.notes} onChange={(e) => setData("notes", e.target.value)} />
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <label htmlFor="task-room">Room</label>
              <Select id="task-room" value={data.room} onChange={(e) => setData("room", e.target.value)}>
                {options.rooms.map((r) => (
                  <option key={r} value={r}>{humanize(r)}</option>
                ))}
              </Select>
            </div>
            <div className="space-y-2">
              <label htmlFor="task-category">Category</label>
              <Select id="task-category" value={data.category} onChange={(e) => setData("category", e.target.value)}>
                {options.categories.map((c) => (
                  <option key={c} value={c}>{humanize(c)}</option>
                ))}
              </Select>
            </div>
            <div className="space-y-2">
              <label htmlFor="task-duration">Minutes</label>
              <Input
                id="task-duration"
                type="number"
                min={1}
                max={240}
                value={data.duration_minutes}
                aria-invalid={!!errors.duration_minutes}
                onChange={(e) => setData("duration_minutes", Number(e.target.value))}
              />
              {error("duration_minutes")}
            </div>
            <div className="space-y-2">
              <label htmlFor="task-effort">Effort</label>
              <Select id="task-effort" value={data.effort} onChange={(e) => setData("effort", e.target.value)}>
                {options.efforts.map((x) => (
                  <option key={x} value={x}>{humanize(x)}</option>
                ))}
              </Select>
            </div>
            <div className="space-y-2">
              <label htmlFor="task-priority">Priority</label>
              <Select id="task-priority" value={data.priority} onChange={(e) => setData("priority", e.target.value)}>
                {options.priorities.map((p) => (
                  <option key={p} value={p}>{humanize(p)}</option>
                ))}
              </Select>
            </div>
            <div className="space-y-2">
              <label htmlFor="task-due">Deadline (optional)</label>
              <Input id="task-due" type="date" value={data.due_on} onChange={(e) => setData("due_on", e.target.value)} />
            </div>
            {members.length > 0 && (
              <div className="space-y-2">
                <label htmlFor="task-assignee">Whose job is it?</label>
                <Select id="task-assignee" value={data.assignee_id} onChange={(e) => setData("assignee_id", e.target.value)}>
                  <option value="">Anyone</option>
                  {members.map((m) => <option key={m.id} value={m.id}>{m.name}</option>)}
                </Select>
              </div>
            )}
          </div>
          {members.length > 0 && data.assignee_id !== "" && data.recurrence_kind !== "none" && (
            <label className="flex items-start gap-3 font-normal text-ink-body">
              <Checkbox className="mt-1" checked={data.rotate} onChange={(e) => setData("rotate", e.target.checked)} />
              <span>
                Take turns
                <span className="block text-sm text-ink-muted">After each time it's done, the next person in your household gets it.</span>
              </span>
            </label>
          )}

          <div className="space-y-2">
            <label htmlFor="task-recurrence">Repeat</label>
            <Select
              id="task-recurrence"
              value={data.recurrence_kind}
              onChange={(e) => setData("recurrence_kind", e.target.value)}
            >
              {options.recurrence_kinds.map((k) => (
                <option key={k} value={k}>{RECURRENCE_LABELS[k] ?? humanize(k)}</option>
              ))}
            </Select>
          </div>

          {data.recurrence_kind === "calendar" && (
            <fieldset className="space-y-2">
              <legend>On these days</legend>
              <div className="flex flex-wrap gap-3">
                {WEEKDAYS.map((name, day) => (
                  <label key={name} className="flex items-center gap-2 font-normal text-ink-body">
                    <Checkbox
                      checked={data.recurrence_weekdays.includes(day)}
                      onChange={() => toggleDay(day)}
                    />
                    {name}
                  </label>
                ))}
              </div>
              {error("recurrence_weekdays")}
            </fieldset>
          )}

          {data.recurrence_kind === "completion" && (
            <div className="space-y-2">
              <label htmlFor="task-interval">Repeat every (days)</label>
              <Input
                id="task-interval"
                type="number"
                min={1}
                max={365}
                value={data.recurrence_interval_days}
                aria-invalid={!!errors.recurrence_interval_days}
                onChange={(e) => setData("recurrence_interval_days", Number(e.target.value))}
              />
              {error("recurrence_interval_days")}
            </div>
          )}

          <DialogFooter>
            <Button type="button" variant="ghost" onClick={() => onOpenChange(false)}>Cancel</Button>
            <Button type="submit" disabled={form.processing}>{quest ? "Save" : "Add quest"}</Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
