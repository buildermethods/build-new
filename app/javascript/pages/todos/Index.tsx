import { FormEvent, useState } from "react"
import { Head, router, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { EmptyState } from "@/components/ui/empty-state"
import { Input } from "@/components/ui/input"

import type { PageProps } from "@/types/inertia"

type TodoItem = { id: number; title: string; done: boolean; completed_at: string | null }

const DESCRIPTION = "A simple checklist for quick one-off things. Add, tick, edit and delete; ticking earns a tiny bit of XP."

function Row({ todo }: { todo: TodoItem }) {
  const [editing, setEditing] = useState(false)
  const [title, setTitle] = useState(todo.title)
  const [error, setError] = useState<string | undefined>()

  const toggle = () =>
    router.post(`/todos/${todo.id}/${todo.done ? "uncomplete" : "complete"}`, {}, { preserveScroll: true })

  const save = (e: FormEvent) => {
    e.preventDefault()
    router.patch(
      `/todos/${todo.id}`,
      { title },
      {
        preserveScroll: true,
        onSuccess: () => {
          setError(undefined)
          setEditing(false)
        },
        onError: (errs) => setError(errs.title),
      },
    )
  }

  return (
    <li className="flex items-start gap-3 py-3">
      <Checkbox
        id={`todo-${todo.id}`}
        className="mt-1"
        checked={todo.done}
        onChange={toggle}
        aria-label={`${todo.done ? "Mark not done" : "Mark done"}: ${todo.title}`}
      />
      {editing ? (
        <form onSubmit={save} className="flex flex-1 flex-wrap items-start gap-2">
          <div className="min-w-0 flex-1 space-y-1">
            <Input aria-label="Edit to-do" autoFocus aria-invalid={!!error} value={title} onChange={(e) => setTitle(e.target.value)} />
            {error && <p className="text-xs text-danger-display">{error}</p>}
          </div>
          <Button type="submit" size="sm">Save</Button>
          <Button type="button" size="sm" variant="ghost" onClick={() => { setTitle(todo.title); setError(undefined); setEditing(false) }}>
            Cancel
          </Button>
        </form>
      ) : (
        <>
          <p className={`flex-1 ${todo.done ? "line-through text-ink-muted" : ""}`}>
            {todo.title}
            <span className="sr-only">{todo.done ? " (done)" : " (to do)"}</span>
          </p>
          <Button size="sm" variant="ghost" aria-label={`Edit ${todo.title}`} onClick={() => setEditing(true)}>Edit</Button>
          <Button
            size="sm"
            variant="ghost"
            aria-label={`Delete ${todo.title}`}
            onClick={() => router.delete(`/todos/${todo.id}`, { preserveScroll: true })}
          >
            Delete
          </Button>
        </>
      )}
    </li>
  )
}

export default function Todos() {
  const { props } = usePage<PageProps<{ open: TodoItem[]; done: TodoItem[]; daily_cap: number }>>()
  const { open, done, daily_cap } = props
  const form = useForm({ title: "" })

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.post("/todos", { preserveScroll: true, onSuccess: () => form.reset() })
  }

  return (
    <>
      <Head title="To-dos">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="To-dos" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="To-dos" description="Quick one-off things, separate from your chores." />

        <form onSubmit={submit} className="mt-8 flex max-w-xl flex-wrap items-end gap-2">
          <div className="min-w-0 flex-1 space-y-2">
            <label htmlFor="new-todo">New to-do</label>
            <Input
              id="new-todo"
              value={form.data.title}
              placeholder="Call the plumber"
              aria-invalid={!!form.errors.title}
              onChange={(e) => form.setData("title", e.target.value)}
            />
            {form.errors.title && <p className="text-xs text-danger-display">{form.errors.title}</p>}
          </div>
          <Button type="submit" disabled={form.processing}>Add</Button>
        </form>

        <section className="mt-8 max-w-xl" aria-label="To do">
          <h2>To do</h2>
          {open.length === 0 ? (
            <EmptyState className="mt-3" title="Nothing to do">Add something above, or enjoy the calm.</EmptyState>
          ) : (
            <ul className="mt-2 divide-y divide-hairline list-none p-0">
              {open.map((t) => <Row key={t.id} todo={t} />)}
            </ul>
          )}
        </section>

        {done.length > 0 && (
          <section className="mt-10 max-w-xl" aria-label="Done">
            <h2>Done</h2>
            <ul className="mt-2 divide-y divide-hairline list-none p-0">
              {done.map((t) => <Row key={t.id} todo={t} />)}
            </ul>
          </section>
        )}

        <p className="mt-10 max-w-xl caption">
          Ticking a to-do earns a little XP, for up to {daily_cap} a day. Chores and quests are where the big rewards are.
        </p>
      </AppShell>
    </>
  )
}
