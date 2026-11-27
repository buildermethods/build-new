import * as React from "react"
import { router } from "@inertiajs/react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { MonsterArt } from "@/components/ui/monster-art"
import { Select } from "@/components/ui/select"

import type { Quest } from "@/types/inertia"

// "Your one thing today": a single clear next action, a way to commit to when
// you'll do it, and easy ways to swap or shrink it. No pressure, no countdown.
export function OneThingCard({
  quest,
  intentionAnchor,
  anchors,
  defaultAnchor,
  onStart,
  onSwap,
  onEasier,
}: {
  quest: Quest
  intentionAnchor: string | null
  anchors: string[]
  defaultAnchor: string | null
  onStart: (quest: Quest) => void
  onSwap: () => void
  onEasier: () => void
}) {
  const [anchor, setAnchor] = React.useState(intentionAnchor ?? defaultAnchor ?? "")
  const planned = intentionAnchor !== null

  return (
    <article className="rounded-2xl border border-hairline bg-surface p-5" aria-label="Your one thing today">
      <div className="flex items-center gap-4">
        <MonsterArt monster={quest.monster.key} className="h-20 w-20" />
        <div>
          <p className="text-sm text-ink-muted">{quest.monster.name}</p>
          <h3 className="mt-1">{quest.fantasy_title}</h3>
        </div>
      </div>
      <p className="mt-3 text-lg">
        <strong>To do:</strong> {quest.title}
      </p>
      <div className="mt-3 flex flex-wrap items-center gap-2">
        <Badge tone="neutral">{quest.duration_minutes} min</Badge>
        <Badge tone="muted">{quest.difficulty}</Badge>
        <Badge tone="signal">+{quest.xp} XP</Badge>
        <Badge tone="signal">+{quest.coins} coins</Badge>
        {planned && <Badge tone="accent">{intentionAnchor ? `Planned: ${intentionAnchor}` : "Planned for today"}</Badge>}
      </div>

      <div className="mt-5 flex flex-wrap gap-2">
        <Button size="lg" onClick={() => onStart(quest)}>Start with 2 minutes</Button>
        <Button
          size="lg"
          variant="secondary"
          aria-label={`Complete ${quest.title}`}
          onClick={() => router.post(`/tasks/${quest.id}/complete`, {}, { preserveScroll: true })}
        >
          I've done it
        </Button>
      </div>

      <div className="mt-5 flex flex-wrap items-end gap-3 border-t border-hairline pt-4">
        <div className="space-y-1">
          <label htmlFor="intention-anchor">When will you do it?</label>
          <Select id="intention-anchor" value={anchor} onChange={(e) => setAnchor(e.target.value)}>
            <option value="">Sometime today</option>
            {anchors.map((a) => (
              <option key={a} value={a}>{a.charAt(0).toUpperCase() + a.slice(1)}</option>
            ))}
          </Select>
        </div>
        <Button
          variant="secondary"
          onClick={() => router.post("/intentions", { task_id: quest.id, anchor }, { preserveScroll: true })}
        >
          {planned ? "Update plan" : "Plan it"}
        </Button>
      </div>

      <div className="mt-4 flex flex-wrap gap-2">
        <Button size="sm" variant="ghost" onClick={onSwap}>Swap for another</Button>
        <Button size="sm" variant="ghost" onClick={onEasier}>Something easier</Button>
        <Button
          size="sm"
          variant="ghost"
          aria-label={`Postpone ${quest.title} until tomorrow`}
          onClick={() => router.post(`/tasks/${quest.id}/defer`, { days: 1 }, { preserveScroll: true })}
        >
          Not today
        </Button>
      </div>
    </article>
  )
}
