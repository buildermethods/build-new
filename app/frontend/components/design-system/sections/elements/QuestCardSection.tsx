import { SectionShell } from "@/components/design-system/SectionShell"
import { Button } from "@/components/ui/button"
import { QuestCard } from "@/components/ui/quest-card"

const code = `<QuestCard
  fantasyTitle="Banish the Counter Goblins"
  title="Wipe kitchen countertops"
  monsterName="Counter Goblins"
  minutes={5}
  difficulty="Easy"
  xp={30}
  coins={15}
  status="Due today"
  actions={<Button size="sm">Complete</Button>}
/>`

export function QuestCardSection() {
  return (
    <SectionShell
      id="quest-card"
      title="Quest card"
      description={
        <>
          A household task presented as a quest. The fantasy title leads, but
          the plain-language task always appears beneath it under "To do".
        </>
      }
      whenToUse={
        <ul>
          <li>Quest Board and suggested-quest lists.</li>
          <li>Anywhere a task is shown with its time, difficulty and rewards.</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>Dense tables of tasks; use the data table instead.</li>
          <li>Hiding the real task behind the fantasy name.</li>
        </ul>
      }
      preview={
        <div className="max-w-md">
          <QuestCard
            fantasyTitle="Banish the Counter Goblins"
            title="Wipe kitchen countertops"
            monsterName="Counter Goblins"
            minutes={5}
            difficulty="Easy"
            xp={30}
            coins={15}
            status="Due today"
            actions={<Button size="sm">Complete</Button>}
          />
        </div>
      }
      code={code}
    />
  )
}
