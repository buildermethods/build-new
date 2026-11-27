import { FormEvent, useState } from "react"
import { Head, router, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"

import type { PageProps, Todo } from "@/types/inertia"

type Filter = "all" | "active" | "completed"

const FILTERS: { value: Filter; label: string }[] = [
  { value: "all", label: "All" },
  { value: "active", label: "Active" },
  { value: "completed", label: "Completed" },
]

const DESCRIPTION = "Keep track of what you need to do: add, edit, complete and delete to-do items."

function TodoRow({ todo }: { todo: Todo }) {
  const [editing, setEditing] = useState(false)
  const [error, setError] = useState<string | undefined>()
  const [description, setDescription] = useState(todo.description)

  const toggle = () =>
    router.patch(`/todos/${todo.id}`, { completed: !todo.completed }, { preserveScroll: true })

  const save = (e: FormEvent) => {
    e.preventDefault()
    router.patch(
      `/todos/${todo.id}`,
      { description },
      {
        preserveScroll: true,
        onSuccess: () => {
          setError(undefined)
          setEditing(false)
        },
        onError: (errs) => setError(errs.description),
      },
    )
  }

  const cancel = () => {
    setDescription(todo.description)
    setError(undefined)
    setEditing(false)
  }

  const remove = () => router.delete(`/todos/${todo.id}`, { preserveScroll: true })

  return (
    <li className="flex items-start gap-3 py-3">
      <Checkbox
        id={`todo-${todo.id}`}
        className="mt-1"
        checked={todo.completed}
        onChange={toggle}
        aria-label={`Mark "${todo.description}" as ${todo.completed ? "incomplete" : "complete"}`}
      />
      {editing ? (
        <form onSubmit={save} className="flex flex-1 flex-wrap items-start gap-2">
          <div className="min-w-0 flex-1 space-y-1">
            <Input
              aria-label="Edit description"
              autoFocus
              aria-invalid={!!error}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
            {error && <p className="text-xs text-danger-display">{error}</p>}
          </div>
          <Button type="submit" size="sm">Save</Button>
          <Button type="button" size="sm" variant="ghost" onClick={cancel}>Cancel</Button>
        </form>
      ) : (
        <>
          <p className={`flex-1 ${todo.completed ? "line-through text-ink-muted" : ""}`}>
            {todo.description}
          </p>
          <Badge tone={todo.completed ? "accent" : "muted"}>
            {todo.completed ? "Complete" : "Incomplete"}
          </Badge>
          <Button size="sm" variant="ghost" onClick={() => setEditing(true)}>Edit</Button>
          <Button size="sm" variant="danger" onClick={remove}>Delete</Button>
        </>
      )}
    </li>
  )
}

export default function Todos() {
  const { props } = usePage<PageProps<{ todos: Todo[] }>>()
  const [filter, setFilter] = useState<Filter>("all")
  const form = useForm({ description: "" })

  const todos = props.todos
  const completedCount = todos.filter((t) => t.completed).length
  const visible = todos.filter((t) =>
    filter === "all" ? true : filter === "completed" ? t.completed : !t.completed,
  )

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.post("/todos", { preserveScroll: true, onSuccess: () => form.reset() })
  }

  return (
    <>
      <Head title="My to-do list">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="My to-do list" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="To-do list" description="Add things to do and check them off." />

        <section className="mt-8 max-w-2xl">
          <form onSubmit={submit} className="flex flex-wrap items-start gap-2">
            <div className="min-w-0 flex-1 space-y-2">
              <label htmlFor="new-todo">New to-do</label>
              <Input
                id="new-todo"
                placeholder="What needs doing?"
                aria-invalid={!!form.errors.description}
                value={form.data.description}
                onChange={(e) => form.setData("description", e.target.value)}
              />
              {form.errors.description && (
                <p className="text-xs text-danger-display">{form.errors.description}</p>
              )}
            </div>
            <Button type="submit" className="mt-8" disabled={form.processing}>Add</Button>
          </form>

          <div className="mt-8 flex flex-wrap items-center justify-between gap-3">
            <div className="flex flex-wrap gap-1.5" role="group" aria-label="Filter to-dos">
              {FILTERS.map((f) => (
                <button
                  key={f.value}
                  type="button"
                  className="toggle-button"
                  aria-pressed={filter === f.value}
                  onClick={() => setFilter(f.value)}
                >
                  {f.label}
                </button>
              ))}
            </div>
            <p aria-live="polite">{completedCount} of {todos.length} complete</p>
          </div>

          {visible.length === 0 ? (
            <p className="mt-6">
              {todos.length === 0 ? "No to-dos yet. Add your first one above." : "No to-dos match this filter."}
            </p>
          ) : (
            <ul className="mt-4 divide-y divide-hairline list-none p-0">
              {visible.map((todo) => (
                <TodoRow key={todo.id} todo={todo} />
              ))}
            </ul>
          )}
        </section>
      </AppShell>
    </>
  )
}
