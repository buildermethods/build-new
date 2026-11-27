import { FormEvent, useState } from "react"
import { Head, Link, router, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"
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
  const { props } = usePage<PageProps<{ settings: { display_name: string | null; reduced_motion: boolean } }>>()
  const errors = props.errors ?? {}
  const form = useForm({
    display_name: props.settings.display_name ?? "",
    reduced_motion: props.settings.reduced_motion,
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

        {props.flash?.notice && <p className="mt-4 text-sm text-accent-display" role="status">{props.flash.notice}</p>}

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
