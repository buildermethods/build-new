import { router } from "@inertiajs/react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { MonsterArt } from "@/components/ui/monster-art"

import type { FocusTarget, QuestPlan } from "@/types/inertia"

export function PlanView({ plan, onStart }: { plan: QuestPlan; onStart: (target: FocusTarget) => void }) {
  return (
    <section aria-label="Your plan" className="space-y-4">
      <div>
        <h2>{plan.title}</h2>
        {plan.intro && <p className="mt-1">{plan.intro}</p>}
      </div>

      {plan.quests.length === 0 ? (
        <p>Try a few more minutes, or a different energy level.</p>
      ) : (
        <ol className="space-y-4">
          {plan.quests.map((q, i) => (
            <li key={q.task_id} className="rounded-xl border border-hairline bg-surface p-4">
              <div className="flex items-center gap-3">
                <MonsterArt monster={q.monster_key} className="h-14 w-14" />
                <div>
                  <h3>{q.real_task}</h3>
                  <p className="caption mt-1">Step {i + 1} · {q.monster}: {q.quest_title}</p>
                </div>
              </div>
              {q.steps.length > 0 && (
                <ul className="mt-2 space-y-1">
                  {q.steps.map((step) => (
                    <li key={step}>– {step}</li>
                  ))}
                </ul>
              )}
              <div className="mt-3 flex flex-wrap items-center gap-2">
                <Badge tone="neutral">{q.estimated_minutes} min</Badge>
                <Badge tone="muted">{q.difficulty}</Badge>
                <Badge tone="signal">+{q.xp} XP</Badge>
                <Badge tone="signal">+{q.coins} coins</Badge>
              </div>
              <div className="mt-4 flex flex-wrap gap-2">
                <Button
                  size="sm"
                  variant="secondary"
                  onClick={() =>
                    onStart({
                      task_id: q.task_id,
                      monster_key: q.monster_key,
                      title: q.real_task,
                      quest_title: q.quest_title,
                      minutes: q.estimated_minutes,
                      steps: q.steps,
                    })
                  }
                >
                  Focus
                </Button>
                <Button
                  size="sm"
                  onClick={() => router.post(`/tasks/${q.task_id}/complete`, {}, { preserveScroll: true })}
                >
                  Complete
                </Button>
              </div>
            </li>
          ))}
        </ol>
      )}

      {plan.quests.length > 0 && (
        <p>
          About {plan.total_minutes} of your {plan.minutes} minutes, leaving {plan.buffer_minutes} free as a buffer.
        </p>
      )}
      {plan.encouragement && <p><em>{plan.encouragement}</em></p>}
      <p className="caption">
        {plan.source === "ai" ? "Themed by the Questmaster." : "Planned from your saved tasks."}
      </p>
    </section>
  )
}
