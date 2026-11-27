import { useState } from "react"
import { Head, Link, router, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { FocusMode } from "@/components/quest/FocusMode"
import { PlanView } from "@/components/quest/PlanView"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { cn } from "@/lib/utils"

import type { EnergyMode, FocusTarget, PageProps, QuestPlan } from "@/types/inertia"

const DESCRIPTION = "Plan your day in three easy steps: how much time you have, how your energy is, then a realistic quest plan."

type Step = "time" | "energy" | "result"
const STEPS: { key: Step; label: string }[] = [
  { key: "time", label: "Time" },
  { key: "energy", label: "Energy" },
  { key: "result", label: "Your plan" },
]

type PlanProps = {
  energy_modes: EnergyMode[]
  time_options: number[]
  checkin: { minutes: number; energy: string; context: string }
  plan: QuestPlan | null
  treat: string | null
}

export default function PlanShow() {
  const { props } = usePage<PageProps<PlanProps>>()
  const { energy_modes, time_options, plan, treat } = props
  const [step, setStep] = useState<Step>(plan ? "result" : "time")
  const [minutes, setMinutes] = useState(props.checkin.minutes)
  const [energy, setEnergy] = useState(props.checkin.energy)
  const [context, setContext] = useState(props.checkin.context)
  const [focus, setFocus] = useState<FocusTarget | null>(null)
  const index = STEPS.findIndex((s) => s.key === step)

  const make = () => {
    router.get("/plan", { minutes, energy, context, plan: 1 }, { preserveState: true, onSuccess: () => setStep("result") })
  }

  return (
    <>
      <Head title="Plan my day">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Plan my day" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Plan my day" description="Three quick steps to a realistic plan." />

        <nav aria-label="Planning progress" className="mt-6">
          <ol className="flex items-center gap-2">
            {STEPS.map((s, i) => (
              <li key={s.key} aria-current={i === index ? "step" : undefined} className="flex flex-1 flex-col gap-1">
                <span className={cn("h-1.5 rounded-full", i <= index ? "bg-accent" : "bg-hairline")} />
                <span className={cn("text-xs", i === index ? "font-semibold text-ink-display" : "text-ink-muted")}>
                  <span className="sr-only">Step {i + 1} of {STEPS.length}: </span>
                  {s.label}
                </span>
              </li>
            ))}
          </ol>
        </nav>

        {step === "time" && (
          <section className="mt-8" aria-label="How much time do you have?">
            <h2>How much time do you have?</h2>
            <div className="mt-4 flex flex-wrap gap-2" role="group" aria-label="Available time">
              {time_options.map((m) => (
                <button key={m} type="button" className="toggle-button" aria-pressed={minutes === m} onClick={() => setMinutes(m)}>
                  {m} min
                </button>
              ))}
            </div>
            <div className="mt-8 flex gap-3">
              <Button asChild variant="ghost"><Link href="/">Back to today</Link></Button>
              <Button size="lg" onClick={() => setStep("energy")}>Next: your energy</Button>
            </div>
          </section>
        )}

        {step === "energy" && (
          <section className="mt-8" aria-label="How is your energy?">
            <h2>How is your energy?</h2>
            <ul className="mt-4 grid list-none gap-3 p-0 sm:grid-cols-2" role="group" aria-label="Energy level">
              {energy_modes.map((m) => (
                <li key={m.key}>
                  <button
                    type="button"
                    aria-pressed={energy === m.key}
                    onClick={() => setEnergy(m.key)}
                    className={cn(
                      "w-full rounded-xl border p-4 text-left",
                      energy === m.key ? "border-accent bg-accent-faded" : "border-hairline bg-surface",
                    )}
                  >
                    <strong>{m.label}</strong>
                    <span className="block text-sm text-ink-muted">{m.description}</span>
                  </button>
                </li>
              ))}
            </ul>
            <div className="mt-6 max-w-xl space-y-2">
              <label htmlFor="plan-context">Anything else going on? (optional)</label>
              <Input
                id="plan-context"
                value={context}
                maxLength={300}
                placeholder="My back hurts and the kitchen looks awful"
                onChange={(e) => setContext(e.target.value)}
              />
            </div>
            <div className="mt-8 flex gap-3">
              <Button variant="ghost" onClick={() => setStep("time")}>Back</Button>
              <Button size="lg" onClick={make}>Make my plan</Button>
            </div>
          </section>
        )}

        {step === "result" && plan && (
          <section className="mt-8">
            <PlanView plan={plan} onStart={setFocus} />
            <div className="mt-8 flex gap-3">
              <Button variant="ghost" onClick={() => setStep("energy")}>Change my answers</Button>
              <Button asChild variant="secondary"><Link href="/">Back to today</Link></Button>
            </div>
          </section>
        )}

        {focus && <FocusMode target={focus} treat={treat} onClose={() => setFocus(null)} />}
      </AppShell>
    </>
  )
}
