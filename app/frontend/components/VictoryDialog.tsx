import * as React from "react"
import { usePage } from "@inertiajs/react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { MonsterArt } from "@/components/ui/monster-art"
import { Confetti } from "@/components/quest/Confetti"

import type { PageProps } from "@/types/inertia"

// Shown after a quest is completed. The server sends the payload once as
// flash.victory; the animation is CSS-only and disabled for reduced motion.
export function VictoryDialog() {
  const { props } = usePage<PageProps>()
  const victory = props.flash?.victory ?? null
  const [shownId, setShownId] = React.useState<number | null>(null)
  const open = victory !== null && shownId !== victory.id

  if (!victory) return null
  const big = victory.leveled_up || victory.badges.length > 0

  return (
    <Dialog open={open} onOpenChange={(next) => !next && setShownId(victory.id)}>
      <DialogContent size="sm">
        {big && <Confetti />}
        <DialogHeader>
          <div className="flex justify-center">
            {victory.monster_key ? (
              <MonsterArt monster={victory.monster_key} mood="sleepy" className="h-24 w-24" />
            ) : (
              <div className="victory-poof" aria-hidden="true">
                <span />
                <span />
                <span />
              </div>
            )}
          </div>
          <DialogTitle>{victory.monster} defeated!</DialogTitle>
          <DialogDescription>
            {victory.message}
          </DialogDescription>
        </DialogHeader>
        <p className="caption">
          {victory.quest_title}: "{victory.task_title}"
        </p>
        <div className="mt-3 flex flex-wrap gap-2">
          <Badge tone="signal">+{victory.xp} XP</Badge>
          <Badge tone="signal">+{victory.coins} coins</Badge>
        </div>
        {victory.leveled_up && (
          <p className="mt-3">
            <strong>Level up!</strong> You reached level {victory.level}.
          </p>
        )}
        {victory.badges.map((b) => (
          <p key={b.key} className="mt-3">
            <strong>New badge: {b.name}.</strong> {b.description}
          </p>
        ))}
        <DialogFooter>
          <Button onClick={() => setShownId(victory.id)}>Lovely</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
