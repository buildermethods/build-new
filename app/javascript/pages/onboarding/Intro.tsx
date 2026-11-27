import { Head, Link, router, usePage } from "@inertiajs/react"
import { WizardShell, type WizardInfo } from "@/components/WizardShell"
import { RoomIcon } from "@/components/ui/room-icon"
import { Button } from "@/components/ui/button"

import type { PageProps } from "@/types/inertia"

const DESCRIPTION =
  "Welcome to Nest Quest. Set up your home in a few quick steps: pick your rooms, choose your chores and how often, and begin your first quest."

export default function Intro() {
  const { props } = usePage<PageProps<{ wizard: WizardInfo }>>()
  const { wizard } = props
  const next = wizard.steps[1].path

  return (
    <>
      <Head title="Welcome to Nest Quest">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Welcome to Nest Quest" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <WizardShell
        wizard={wizard}
        title="Welcome to Nest Quest"
        description="Your real chores become quests. Finish them to earn XP and coins, then spend the coins making your cottage cosier. Skip or postpone anything, any time, with no penalty."
        footer={
          <>
            <Button asChild size="lg">
              <Link href={next}>Let's set up my home</Link>
            </Button>
            <Button type="button" size="lg" variant="ghost" onClick={() => router.post("/welcome/skip")}>
              Skip for now
            </Button>
          </>
        }
      >
        <ul className="grid list-none grid-cols-3 gap-4 p-0 sm:grid-cols-5" aria-label="What we will set up">
          {["kitchen", "bedroom", "bathroom", "living_room", "garden"].map((room) => (
            <li key={room} className="flex justify-center">
              <RoomIcon room={room} className="h-16 w-16" />
            </li>
          ))}
        </ul>
        <ol className="mt-8 space-y-3">
          <li><strong>1. Your rooms.</strong> Tell us which rooms you have.</li>
          <li><strong>2. Your chores.</strong> We suggest the usual housework for each room.</li>
          <li><strong>3. How often.</strong> Sensible defaults, all editable.</li>
          <li><strong>4. Begin.</strong> A first small quest, ready in under two minutes.</li>
        </ol>
      </WizardShell>
    </>
  )
}
