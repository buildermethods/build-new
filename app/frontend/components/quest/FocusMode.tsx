import * as React from "react"
import { router } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"

import type { FocusTarget } from "@/types/inertia"

const clock = (seconds: number) =>
  `${String(Math.floor(seconds / 60)).padStart(2, "0")}:${String(seconds % 60).padStart(2, "0")}`

// One task, one clear action. The timer is optional and client-only.
export function FocusMode({ target, onClose }: { target: FocusTarget; onClose: () => void }) {
  const [seconds, setSeconds] = React.useState(0)
  const [running, setRunning] = React.useState(false)

  React.useEffect(() => {
    if (!running) return
    const id = window.setInterval(() => setSeconds((s) => s + 1), 1000)
    return () => window.clearInterval(id)
  }, [running])

  const post = (path: string) =>
    router.post(path, {}, { preserveScroll: true, onSuccess: onClose })

  return (
    <Dialog open onOpenChange={(open) => !open && onClose()}>
      <DialogContent size="md">
        <DialogHeader>
          <DialogTitle>{target.title}</DialogTitle>
          <DialogDescription>
            {target.quest_title} · about {target.minutes} min
          </DialogDescription>
        </DialogHeader>

        {target.steps.length > 0 && (
          <ol className="list-decimal space-y-1 pl-5">
            {target.steps.map((step) => (
              <li key={step} className="pl-1">{step}</li>
            ))}
          </ol>
        )}

        <div className="mt-4 flex items-center gap-3">
          <p aria-label="Elapsed time" role="timer">
            <strong>{clock(seconds)}</strong>
          </p>
          <Button size="sm" variant="secondary" onClick={() => setRunning((r) => !r)}>
            {running ? "Pause timer" : seconds > 0 ? "Resume timer" : "Start timer"}
          </Button>
        </div>

        <DialogFooter>
          <Button variant="ghost" onClick={onClose}>Back to the board</Button>
          <Button variant="secondary" onClick={() => post(`/tasks/${target.task_id}/skip`)}>Skip</Button>
          <Button onClick={() => post(`/tasks/${target.task_id}/complete`)}>Complete</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
