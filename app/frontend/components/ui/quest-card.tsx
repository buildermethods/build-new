// Quest card: a household task dressed as a quest. The plain-language task
// is always shown beneath the fantasy title so the real action stays clear.
import * as React from "react"
import { Badge } from "@/components/ui/badge"
import { MonsterArt } from "@/components/ui/monster-art"
import { cn } from "@/lib/utils"

export interface QuestCardProps extends React.HTMLAttributes<HTMLElement> {
  fantasyTitle: string
  title: string
  monsterName: string
  /** Catalogue key (e.g. "counter_goblins") to show the monster illustration. */
  monsterKey?: string
  minutes: number
  difficulty: string
  xp: number
  coins: number
  /** Short plain-text status, e.g. "Due today" or "Back tomorrow". */
  status?: string
  /** Action buttons rendered in the footer. */
  actions?: React.ReactNode
}

const QuestCard = React.forwardRef<HTMLElement, QuestCardProps>(
  (
    { fantasyTitle, title, monsterName, monsterKey, minutes, difficulty, xp, coins, status, actions, className, ...props },
    ref,
  ) => (
    <article
      ref={ref}
      className={cn("rounded-xl border border-hairline bg-surface p-4", className)}
      {...props}
    >
      <div className="flex items-center gap-3">
        {monsterKey && <MonsterArt monster={monsterKey} className="h-14 w-14" />}
        <div>
          <p className="text-sm text-ink-muted">{monsterName}</p>
          <h3 className="mt-1">{fantasyTitle}</h3>
        </div>
      </div>
      <p className="mt-1">
        <strong>To do:</strong> {title}
      </p>
      <div className="mt-3 flex flex-wrap items-center gap-2">
        <Badge tone="neutral">{minutes} min</Badge>
        <Badge tone="muted">{difficulty}</Badge>
        <Badge tone="signal">+{xp} XP</Badge>
        <Badge tone="signal">+{coins} coins</Badge>
        {status && <Badge tone="accent">{status}</Badge>}
      </div>
      {actions && <div className="mt-4 flex flex-wrap gap-2">{actions}</div>}
    </article>
  ),
)
QuestCard.displayName = "QuestCard"

export { QuestCard }
