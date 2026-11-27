import { FormEvent, useState } from "react"
import { Head, Link, router, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
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

import type { PageProps } from "@/types/inertia"

const DESCRIPTION = "Choose your display name, reduce motion, or reset your Nest Quest game data."

export default function Settings() {
  const { props } = usePage<
    PageProps<{
      settings: { display_name: string | null; reduced_motion: boolean; anchor: string | null; treat: string | null }
      anchors: string[]
    }>
  >()
  const errors = props.errors ?? {}
  const form = useForm({
    display_name: props.settings.display_name ?? "",
    reduced_motion: props.settings.reduced_motion,
    anchor: props.settings.anchor ?? "",
    treat: props.settings.treat ?? "",
  })
  const [confirmReset, setConfirmReset] = useState(false)

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.patch("/settings", { preserveScroll: true })
  }

  return (
    <>
      <Head title="Settings">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Settings" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Settings" description="Make Nest Quest fit you." />

        <form onSubmit={submit} className="mt-8 max-w-md space-y-6">
          <div className="space-y-2">
            <label htmlFor="display-name">Display name</label>
            <Input
              id="display-name"
              value={form.data.display_name}
              maxLength={40}
              aria-invalid={!!errors.display_name}
              onChange={(e) => form.setData("display_name", e.target.value)}
            />
            {errors.display_name && <p className="text-xs text-danger-display">{errors.display_name}</p>}
          </div>

          <div className="space-y-2">
            <label htmlFor="anchor">When do you usually have a quiet few minutes?</label>
            <Select id="anchor" value={form.data.anchor} onChange={(e) => form.setData("anchor", e.target.value)}>
              <option value="">No preference</option>
              {props.anchors.map((a) => (
                <option key={a} value={a}>{a.charAt(0).toUpperCase() + a.slice(1)}</option>
              ))}
            </Select>
            <p className="text-sm text-ink-muted">Used as the default when you plan when to do your one thing.</p>
            {errors.anchor && <p className="text-xs text-danger-display">{errors.anchor}</p>}
          </div>

          <div className="space-y-2">
            <label htmlFor="treat">A treat to pair with chores</label>
            <Input
              id="treat"
              value={form.data.treat}
              maxLength={60}
              placeholder="A favourite podcast"
              aria-invalid={!!errors.treat}
              onChange={(e) => form.setData("treat", e.target.value)}
            />
            <p className="text-sm text-ink-muted">Shown as a gentle reminder when you start a task.</p>
            {errors.treat && <p className="text-xs text-danger-display">{errors.treat}</p>}
          </div>

          <label className="flex items-start gap-3 font-normal text-ink-body">
            <Checkbox
              className="mt-1"
              checked={form.data.reduced_motion}
              onChange={(e) => form.setData("reduced_motion", e.target.checked)}
            />
            <span>
              Reduce motion
              <span className="block text-sm text-ink-muted">Turns off animations, even if your device allows them.</span>
            </span>
          </label>

          <Button type="submit" disabled={form.processing}>Save settings</Button>
        </form>

        <section className="mt-12 max-w-xl" aria-label="How this works">
          <h2>How this works</h2>
          <p className="mt-2">
            Nest Quest uses a few well-known habit ideas, always kindly. Here is exactly what it does, and what it never will.
          </p>
          <ul className="mt-3 list-disc space-y-2 pl-5">
            <li><strong>One thing at a time.</strong> Today shows a single suggested quest so you aren't facing a long list.</li>
            <li><strong>Plan when, not just what.</strong> Choosing a moment ("after dinner") makes it far more likely you'll start.</li>
            <li><strong>Starting counts.</strong> The 2-minute button earns a little XP, and stopping early is fine.</li>
            <li><strong>Flexible weeks.</strong> The week ring aims for 4 active days. A quiet day never resets anything.</li>
            <li><strong>Milestones, not chance.</strong> Badges unlock at fixed targets and are never taken away.</li>
            <li><strong>Never:</strong> streaks that reset, countdown timers, random prizes, or guilt messages.</li>
          </ul>
          <p className="mt-3">
            See your <Link href="/achievements">badges</Link> any time.
          </p>
        </section>

        <section className="mt-12 max-w-md" aria-label="Suggested chores">
          <h2>Suggested chores</h2>
          <p className="mt-2">Add more of the usual housework for any room, with sensible frequencies.</p>
          <Button asChild className="mt-4" variant="secondary">
            <Link href="/add-chores/rooms">Add suggested chores</Link>
          </Button>
        </section>

        <section className="mt-12 max-w-md" aria-label="Reset">
          <h2>Reset game data</h2>
          <p className="mt-2">
            Deletes your tasks, routines, XP, coins and cottage, then restarts the welcome flow. Your account stays.
          </p>
          <Button className="mt-4" variant="danger" onClick={() => setConfirmReset(true)}>Reset my game data</Button>
        </section>

        <Dialog open={confirmReset} onOpenChange={setConfirmReset}>
          <DialogContent size="sm">
            <DialogHeader>
              <DialogTitle>Reset everything?</DialogTitle>
              <DialogDescription>This cannot be undone.</DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="ghost" onClick={() => setConfirmReset(false)}>Cancel</Button>
              <Button variant="danger" onClick={() => router.post("/settings/reset")}>Yes, reset</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </AppShell>
    </>
  )
}
