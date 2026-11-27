import * as React from "react"
import { Link } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

export type WizardInfo = {
  mode: "setup" | "add"
  steps: { key: string; label: string; path: string }[]
  current: string
  back_path: string | null
}

// One screen of the step-by-step setup: a progress stepper, a single heading,
// and the controls for that one decision. Focus moves to the heading on each
// new step so keyboard and screen-reader users land at the top.
export function WizardShell({
  wizard,
  title,
  description,
  children,
  footer,
}: {
  wizard: WizardInfo
  title: string
  description?: React.ReactNode
  children: React.ReactNode
  footer: React.ReactNode
}) {
  const headingRef = React.useRef<HTMLHeadingElement>(null)
  React.useEffect(() => {
    headingRef.current?.focus()
  }, [wizard.current])
  const index = wizard.steps.findIndex((s) => s.key === wizard.current)

  return (
    <main className="mx-auto max-w-2xl px-6 py-10">
      <nav aria-label="Setup progress">
        <ol className="flex items-center gap-2">
          {wizard.steps.map((s, i) => (
            <li
              key={s.key}
              aria-current={i === index ? "step" : undefined}
              className="flex flex-1 flex-col gap-1"
            >
              <span
                className={cn(
                  "h-1.5 rounded-full",
                  i <= index ? "bg-accent" : "bg-hairline",
                )}
              />
              <span className={cn("text-xs", i === index ? "font-semibold text-ink-display" : "text-ink-muted")}>
                <span className="sr-only">Step {i + 1} of {wizard.steps.length}: </span>
                {s.label}
              </span>
            </li>
          ))}
        </ol>
      </nav>

      <h1 ref={headingRef} tabIndex={-1} className="mt-8 focus:outline-none">{title}</h1>
      {description && <p className="mt-2">{description}</p>}

      <div className="mt-8">{children}</div>

      <div className="sticky bottom-0 -mx-6 mt-10 flex flex-wrap items-center gap-3 border-t border-hairline bg-page/95 px-6 py-4 backdrop-blur">
        {wizard.back_path && (
          <Button asChild variant="ghost">
            <Link href={wizard.back_path}>Back</Link>
          </Button>
        )}
        {footer}
      </div>
    </main>
  )
}
