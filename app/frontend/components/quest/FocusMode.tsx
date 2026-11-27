import * as React from "react"
import { router } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import { MonsterArt } from "@/components/ui/monster-art"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"

import type { FocusTarget } from "@/types/inertia"

const TWO_MINUTES = 120

const clock = (seconds: number) =>
  `${String(Math.floor(seconds / 60)).padStart(2, "0")}:${String(seconds % 60).padStart(2, "0")}`

type Mode = "idle" | "two" | "free"

// One task, one clear action. "Just 2 minutes" lowers the barrier to starting:
// beginning counts (a small XP award, once), and stopping after two minutes is
// fine. The timers are optional and client-only.
export function FocusMode({
  target,
  treat,
  onClose,
}: {
  target: FocusTarget
  treat?: string | null
  onClose: () => void
}) {
  const [mode, setMode] = React.useState<Mode>("idle")
  const [seconds, setSeconds] = React.useState(0)
  const [running, setRunning] = React.useState(false)

  React.useEffect(() => {
    if (!running) return
    const id = window.setInterval(() => setSeconds((s) => s + 1), 1000)
    return () => window.clearInterval(id)
  }, [running])

  const post = (path: string, onSuccess?: () => void) =>
    router.post(path, {}, { preserveScroll: true, onSuccess })

  const [started, setStarted] = React.useState<number | null>(null)

  const begin = (next: Mode) => {
    setMode(next)
    setSeconds(0)
    setRunning(true)
    // Beginning earns a small one-off XP. A plain fetch (not an Inertia visit)
    // so nothing else is navigated or refreshed under the player.
    const token = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content ?? ""
    fetch(`/tasks/${target.task_id}/start`, {
      method: "POST",
      headers: { "X-CSRF-Token": token, Accept: "application/json" },
      credentials: "same-origin",
    })
      .then((r) => (r.ok ? r.json() : null))
      .then((data) => data?.awarded && setStarted(data.xp))
      .catch(() => undefined)
  }

  const twoDone = mode === "two" && seconds >= TWO_MINUTES
  const remaining = Math.max(0, TWO_MINUTES - seconds)

  return (
    <Dialog open onOpenChange={(open) => !open && onClose()}>
      <DialogContent size="md">
        <DialogHeader>
          <div className="flex items-center gap-3">
            {target.monster_key && <MonsterArt monster={target.monster_key} className="h-16 w-16" />}
            <div>
              <DialogTitle>{target.title}</DialogTitle>
              <DialogDescription>
                {target.quest_title} · about {target.minutes} min
              </DialogDescription>
            </div>
          </div>
        </DialogHeader>

        {target.steps.length > 0 && (
          <ol className="list-decimal space-y-1 pl-5">
            {target.steps.map((step) => (
              <li key={step} className="pl-1">{step}</li>
            ))}
          </ol>
        )}

        {treat && <p className="mt-3 caption">Pair it with a treat: {treat}.</p>}

        <div className="mt-4 space-y-3">
          {mode === "idle" && (
            <>
              <p>Not feeling it? Just start. Two minutes is enough, and starting counts.</p>
              <div className="flex flex-wrap gap-2">
                <Button onClick={() => begin("two")}>Just 2 minutes</Button>
                <Button variant="secondary" onClick={() => begin("free")}>Start timer</Button>
              </div>
            </>
          )}

          {mode !== "idle" && (
            <div className="flex flex-wrap items-center gap-3">
              <p role="timer" aria-label={mode === "two" ? "Time left in your two minutes" : "Elapsed time"}>
                <strong>{clock(mode === "two" ? remaining : seconds)}</strong>
              </p>
              {!twoDone && (
                <Button size="sm" variant="secondary" onClick={() => setRunning((r) => !r)}>
                  {running ? "Pause" : "Resume"}
                </Button>
              )}
            </div>
          )}

          {started !== null && (
            <p role="status">Started! +{started} XP. Starting counts, even if you stop early.</p>
          )}

          {twoDone && (
            <p role="status">
              <strong>Two minutes done!</strong> Keep going, or stop here. Either way it counts.
            </p>
          )}
        </div>

        <DialogFooter>
          <Button variant="ghost" onClick={onClose}>
            {twoDone || (mode !== "idle") ? "That's enough for now" : "Back"}
          </Button>
          <Button variant="secondary" onClick={() => post(`/tasks/${target.task_id}/skip`, onClose)}>Skip</Button>
          <Button onClick={() => post(`/tasks/${target.task_id}/complete`, onClose)}>Complete</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
