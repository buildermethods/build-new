// Room icon: a small illustrated glyph per room, drawn with design tokens so
// it follows light and dark mode. Decorative by default (the room name is
// always shown beside it); pass `label` to expose it to screen readers.
import * as React from "react"
import { cn } from "@/lib/utils"

const ART: Record<string, React.ReactNode> = {
  kitchen: (
    <g>
      <rect x="6" y="20" width="36" height="20" rx="3" className="fill-peach" />
      <rect x="10" y="12" width="12" height="8" rx="2" className="fill-accent" />
      <circle cx="30" cy="30" r="4" className="fill-surface" />
      <circle cx="18" cy="30" r="4" className="fill-surface" />
      <rect x="26" y="14" width="12" height="3" rx="1.5" className="fill-forest" />
    </g>
  ),
  living_room: (
    <g>
      <rect x="6" y="20" width="36" height="16" rx="5" className="fill-coral" />
      <rect x="10" y="14" width="28" height="12" rx="4" className="fill-coral-faded" />
      <rect x="8" y="36" width="4" height="4" className="fill-forest" />
      <rect x="36" y="36" width="4" height="4" className="fill-forest" />
    </g>
  ),
  bedroom: (
    <g>
      <rect x="6" y="14" width="4" height="26" className="fill-peach-display" />
      <rect x="6" y="26" width="36" height="10" rx="3" className="fill-accent" />
      <rect x="10" y="20" width="12" height="8" rx="3" className="fill-surface" />
      <rect x="38" y="30" width="4" height="10" className="fill-peach-display" />
    </g>
  ),
  bathroom: (
    <g>
      <rect x="6" y="22" width="36" height="14" rx="6" className="fill-accent" />
      <rect x="8" y="18" width="10" height="6" rx="3" className="fill-accent-faded stroke-accent-strong" strokeWidth="1.5" />
      <circle cx="34" cy="14" r="2" className="fill-signal" />
      <circle cx="38" cy="10" r="1.5" className="fill-signal" />
      <rect x="10" y="36" width="4" height="4" className="fill-forest" />
      <rect x="34" y="36" width="4" height="4" className="fill-forest" />
    </g>
  ),
  hallway: (
    <g>
      <rect x="12" y="8" width="24" height="32" rx="3" className="fill-peach-display" />
      <rect x="16" y="12" width="16" height="12" rx="2" className="fill-peach" />
      <circle cx="31" cy="28" r="2" className="fill-signal" />
    </g>
  ),
  kids_room: (
    <g>
      <rect x="8" y="26" width="14" height="14" rx="2" className="fill-signal" />
      <rect x="26" y="20" width="14" height="20" rx="2" className="fill-coral" />
      <rect x="14" y="14" width="12" height="12" rx="2" className="fill-accent" />
    </g>
  ),
  utility: (
    <g>
      <rect x="10" y="8" width="28" height="32" rx="4" className="fill-surface stroke-forest" strokeWidth="2" />
      <circle cx="24" cy="26" r="9" className="fill-accent-faded stroke-forest" strokeWidth="2" />
      <circle cx="16" cy="14" r="2" className="fill-accent" />
    </g>
  ),
  office: (
    <g>
      <rect x="6" y="30" width="36" height="5" rx="2" className="fill-peach-display" />
      <rect x="14" y="12" width="20" height="14" rx="2" className="fill-forest" />
      <rect x="16" y="14" width="16" height="10" className="fill-accent-faded" />
      <rect x="22" y="26" width="4" height="4" className="fill-forest" />
    </g>
  ),
  garden: (
    <g>
      <rect x="20" y="22" width="4" height="18" className="fill-leaf-strong" />
      <circle cx="22" cy="16" r="7" className="fill-peach" />
      <circle cx="22" cy="16" r="3" className="fill-signal" />
      <path d="M24 32 q10 -2 12 -10 q-10 0 -12 10 Z" className="fill-leaf" />
      <rect x="6" y="38" width="36" height="3" rx="1.5" className="fill-leaf-faded" />
    </g>
  ),
  home: (
    <g>
      <path d="M8 24 L24 10 L40 24 V40 H8 Z" className="fill-peach" />
      <path d="M6 25 L24 8 L42 25" className="fill-none stroke-peach-display" strokeWidth="3" strokeLinecap="round" />
      <rect x="20" y="28" width="8" height="12" rx="1" className="fill-accent" />
    </g>
  ),
}

export interface RoomIconProps extends React.SVGAttributes<SVGSVGElement> {
  room: string
  label?: string
}

export function RoomIcon({ room, label, className, ...props }: RoomIconProps) {
  return (
    <svg
      viewBox="0 0 48 48"
      className={cn("h-10 w-10 shrink-0", className)}
      role={label ? "img" : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : true}
      {...props}
    >
      {ART[room] ?? ART.home}
    </svg>
  )
}
