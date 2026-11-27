import { SectionShell } from "@/components/design-system/SectionShell"
import { XpBar } from "@/components/ui/xp-bar"

const code = `<XpBar level={7} xpIntoLevel={68} xpForNextLevel={100} coins={420} />`

export function XpBarSection() {
  return (
    <SectionShell
      id="xp-bar"
      title="XP bar"
      description={<>Shows the player's level, progress to the next level and coin balance. Exposed to screen readers as a progress bar.</>}
      whenToUse={
        <ul>
          <li>The top of every signed-in page.</li>
          <li>Anywhere progress toward a level is shown.</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>Generic task progress (use a plain progress bar).</li>
        </ul>
      }
      preview={
        <div className="max-w-md">
          <XpBar level={7} xpIntoLevel={68} xpForNextLevel={100} coins={420} />
        </div>
      }
      code={code}
    />
  )
}
