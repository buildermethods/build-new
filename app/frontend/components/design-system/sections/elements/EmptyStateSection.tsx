import { SectionShell } from "@/components/design-system/SectionShell"
import { Button } from "@/components/ui/button"
import { EmptyState } from "@/components/ui/empty-state"

const code = `<EmptyState
  monster="counter_goblins"
  title="No quests yet"
  action={<Button>Add a quest</Button>}
>
  Add your first chore and meet the monster that goes with it.
</EmptyState>`

export function EmptyStateSection() {
  return (
    <SectionShell
      id="empty-state"
      title="Empty state"
      description={<>A sleepy monster, a short kind message and an optional action for lists with nothing in them yet. It always says what to do next, and never shames.</>}
      whenToUse={
        <ul>
          <li>A list that is genuinely empty (no quests, no to-dos, no battles).</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>When filters hide everything; use a plain sentence there.</li>
        </ul>
      }
      preview={
        <div className="max-w-md">
          <EmptyState monster="counter_goblins" title="No quests yet" action={<Button size="sm">Add a quest</Button>}>
            Add your first chore and meet the monster that goes with it.
          </EmptyState>
        </div>
      }
      code={code}
    />
  )
}
