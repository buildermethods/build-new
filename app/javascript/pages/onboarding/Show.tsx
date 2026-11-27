import { FormEvent, useState } from "react"
import { Head, router, useForm, usePage } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"

import type { PageProps, StarterTask } from "@/types/inertia"

const DESCRIPTION =
  "Welcome to Nest Quest. Pick a few starter chores, name yourself, and begin your first quest in under two minutes. Everything stays editable."

const humanize = (v: string) => v.replace(/_/g, " ").replace(/^./, (c) => c.toUpperCase())

export default function Onboarding() {
  const { props } = usePage<PageProps<{ starter_tasks: StarterTask[] }>>()
  const tasks = props.starter_tasks
  const [selected, setSelected] = useState<string[]>(tasks.slice(0, 4).map((t) => t.key))
  const form = useForm({ display_name: "" })

  const toggle = (key: string) =>
    setSelected((s) => (s.includes(key) ? s.filter((k) => k !== key) : [...s, key]))

  const submit = (e: FormEvent) => {
    e.preventDefault()
    router.post("/welcome", { display_name: form.data.display_name, task_keys: selected })
  }

  return (
    <>
      <Head title="Welcome to Nest Quest">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Welcome to Nest Quest" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <main className="mx-auto max-w-2xl px-6 py-12">
        <h1>Welcome to Nest Quest</h1>
        <p className="mt-2">
          Your real chores become quests. Finish them to earn XP and coins, then spend the coins making your cottage
          cosier. Skip or postpone anything, any time, with no penalty.
        </p>

        <form onSubmit={submit} className="mt-8 space-y-8">
          <div className="max-w-sm space-y-2">
            <label htmlFor="display-name">What should we call you? (optional)</label>
            <Input
              id="display-name"
              value={form.data.display_name}
              maxLength={40}
              onChange={(e) => form.setData("display_name", e.target.value)}
            />
          </div>

          <fieldset className="space-y-3">
            <legend>Pick some starter chores</legend>
            <p className="text-sm text-ink-muted">You can edit or remove all of these later.</p>
            <ul className="space-y-2">
              {tasks.map((t) => (
                <li key={t.key}>
                  <label className="flex items-start gap-3 font-normal text-ink-body">
                    <Checkbox className="mt-1" checked={selected.includes(t.key)} onChange={() => toggle(t.key)} />
                    <span>
                      {t.title}
                      <span className="block text-sm text-ink-muted">
                        {humanize(t.room)} · about {t.duration_minutes} min
                      </span>
                    </span>
                  </label>
                </li>
              ))}
            </ul>
          </fieldset>

          <div className="flex flex-wrap gap-3">
            <Button type="submit" size="lg">Begin my adventure</Button>
            <Button type="button" size="lg" variant="ghost" onClick={() => router.post("/welcome/skip")}>
              Skip for now
            </Button>
          </div>
        </form>
      </main>
    </>
  )
}
