import { useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { WizardShell, type WizardInfo } from "@/components/WizardShell"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select } from "@/components/ui/select"

import type { PageProps } from "@/types/inertia"

const DESCRIPTION = "Almost done. Tell Nest Quest what to call you and when you usually have a quiet few minutes, then begin your first quest."

export default function Finish() {
  const { props } = usePage<
    PageProps<{
      wizard: WizardInfo
      summary: { rooms: number; chores: number }
      anchors: string[]
      draft: { display_name: string | null; anchor: string | null; treat: string | null }
    }>
  >()
  const { wizard, summary, anchors } = props
  const [name, setName] = useState(props.draft.display_name ?? "")
  const [anchor, setAnchor] = useState(props.draft.anchor ?? "")
  const [treat, setTreat] = useState(props.draft.treat ?? "")

  return (
    <>
      <Head title="Almost done">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Almost done" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <WizardShell
        wizard={wizard}
        title="Almost there!"
        description={`You've chosen ${summary.chores} ${summary.chores === 1 ? "chore" : "chores"}. We'll spread them out so your first days stay light.`}
        footer={
          <Button
            size="lg"
            onClick={() => router.post("/welcome/finish", { display_name: name, anchor, treat })}
          >
            Begin my adventure
          </Button>
        }
      >
        <div className="max-w-md space-y-6">
          <div className="space-y-2">
            <label htmlFor="display-name">What should we call you? (optional)</label>
            <Input id="display-name" value={name} maxLength={40} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="space-y-2">
            <label htmlFor="anchor">When do you usually have a quiet few minutes? (optional)</label>
            <Select id="anchor" value={anchor} onChange={(e) => setAnchor(e.target.value)}>
              <option value="">No preference</option>
              {anchors.map((a) => (
                <option key={a} value={a}>{a.charAt(0).toUpperCase() + a.slice(1)}</option>
              ))}
            </Select>
            <p className="caption">We'll suggest your one thing for the day at that time.</p>
          </div>
          <div className="space-y-2">
            <label htmlFor="treat">A treat to pair with chores? (optional)</label>
            <Input id="treat" value={treat} maxLength={60} placeholder="A favourite podcast" onChange={(e) => setTreat(e.target.value)} />
          </div>
        </div>
      </WizardShell>
    </>
  )
}
