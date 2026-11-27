// XP bar: level, progress to the next level, and coin balance.
import * as React from "react"
import { cn } from "@/lib/utils"

export interface XpBarProps extends React.HTMLAttributes<HTMLDivElement> {
  level: number
  xpIntoLevel: number
  xpForNextLevel: number
  coins: number
}

const XpBar = React.forwardRef<HTMLDivElement, XpBarProps>(
  ({ level, xpIntoLevel, xpForNextLevel, coins, className, ...props }, ref) => {
    const percent = Math.min(100, Math.round((xpIntoLevel / xpForNextLevel) * 100))
    return (
      <div ref={ref} className={cn("rounded-xl border border-hairline bg-surface px-4 py-3", className)} {...props}>
        <div className="flex flex-wrap items-baseline justify-between gap-2">
          <p>
            <strong>Level {level}</strong>
          </p>
          <p>
            <strong>{coins}</strong> coins
          </p>
        </div>
        <div
          className="mt-2 h-2 overflow-hidden rounded-full bg-hairline"
          role="progressbar"
          aria-label={`Level ${level} progress`}
          aria-valuemin={0}
          aria-valuemax={xpForNextLevel}
          aria-valuenow={xpIntoLevel}
        >
          <div className="h-full rounded-full bg-accent transition-all" style={{ width: `${percent}%` }} />
        </div>
        <p className="mt-1 caption">
          {xpIntoLevel} / {xpForNextLevel} XP to level {level + 1}
        </p>
      </div>
    )
  },
)
XpBar.displayName = "XpBar"

export { XpBar }
