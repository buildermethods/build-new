// Empty state: a friendly illustration, a short message and an optional action
// for lists that have nothing in them yet. Never shames; always says what to do.
import * as React from "react"
import { MonsterArt } from "@/components/ui/monster-art"
import { cn } from "@/lib/utils"

export interface EmptyStateProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Monster to keep the player company; defaults to a sleepy dust bunny. */
  monster?: string
  title: string
  action?: React.ReactNode
}

export function EmptyState({ monster = "dust_bunny_horde", title, action, children, className, ...props }: EmptyStateProps) {
  return (
    <div
      className={cn("flex flex-col items-center gap-3 rounded-2xl border border-dashed border-hairline bg-surface px-6 py-8 text-center", className)}
      {...props}
    >
      <MonsterArt monster={monster} mood="sleepy" className="h-20 w-20" />
      <h3>{title}</h3>
      {children && <p className="max-w-md">{children}</p>}
      {action && <div className="mt-1 flex flex-wrap justify-center gap-2">{action}</div>}
    </div>
  )
}
