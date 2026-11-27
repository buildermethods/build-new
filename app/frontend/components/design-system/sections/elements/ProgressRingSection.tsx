import { SectionShell } from "@/components/design-system/SectionShell"
import { ProgressRing } from "@/components/ui/progress-ring"

const code = `<ProgressRing value={2} max={3} center="2/3" label="Today's wins" />`

export function ProgressRingSection() {
  return (
    <SectionShell
      id="progress-ring"
      title="Progress ring"
      description={<>A circular meter with a short label in the middle. Exposed to screen readers as a progress bar. It fills smoothly, and stays still when motion is reduced.</>}
      whenToUse={
        <ul>
          <li>Today's wins and days active this week.</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>Anything that resets to zero as a penalty; progress should only ever go forward.</li>
        </ul>
      }
      preview={
        <div className="flex gap-6">
          <ProgressRing value={0} max={3} center="0/3" label="Empty example" />
          <ProgressRing value={2} max={3} center="2/3" label="Partial example" />
          <ProgressRing value={4} max={4} center="4/4" label="Complete example" />
        </div>
      }
      code={code}
    />
  )
}
