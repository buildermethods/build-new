// Progress ring: a circular meter with a label in the middle. Exposed to
// screen readers as a progress bar with a plain-text description.
import * as React from "react"
import { cn } from "@/lib/utils"

export interface ProgressRingProps extends React.HTMLAttributes<HTMLDivElement> {
  value: number
  max: number
  /** Big text in the centre, e.g. "2/3". */
  center: React.ReactNode
  /** Accessible name, e.g. "Today's wins". */
  label: string
  size?: number
}

export function ProgressRing({ value, max, center, label, size = 96, className, ...props }: ProgressRingProps) {
  const stroke = 8
  const radius = (size - stroke) / 2
  const circumference = 2 * Math.PI * radius
  const ratio = max > 0 ? Math.min(1, value / max) : 0

  return (
    <div
      className={cn("relative inline-flex items-center justify-center", className)}
      style={{ width: size, height: size }}
      role="progressbar"
      aria-label={label}
      aria-valuemin={0}
      aria-valuemax={max}
      aria-valuenow={Math.min(value, max)}
      {...props}
    >
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className="-rotate-90" aria-hidden="true">
        <circle cx={size / 2} cy={size / 2} r={radius} fill="none" strokeWidth={stroke} className="stroke-hairline" />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          strokeWidth={stroke}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - ratio)}
          className="stroke-accent-strong transition-[stroke-dashoffset] duration-700"
        />
      </svg>
      <span className="absolute text-center font-semibold leading-tight text-ink-display">{center}</span>
    </div>
  )
}
