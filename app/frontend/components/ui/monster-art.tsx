// Monster art: a charming, never-scary character for each chore monster, drawn
// with design tokens so it follows light and dark mode. Placeholder-quality
// illustration; swap the drawings later, the keys match config/game/monsters.yml.
import * as React from "react"
import { cn } from "@/lib/utils"

const Eyes = ({ x = 0, y = 0, gap = 12 }: { x?: number; y?: number; gap?: number }) => (
  <g transform={`translate(${x} ${y})`}>
    <circle cx={32 - gap / 2} cy="30" r="4" className="fill-surface" />
    <circle cx={32 + gap / 2} cy="30" r="4" className="fill-surface" />
    <circle cx={32 - gap / 2 + 1} cy="31" r="2" className="fill-forest" />
    <circle cx={32 + gap / 2 + 1} cy="31" r="2" className="fill-forest" />
  </g>
)

const Smile = ({ y = 40 }: { y?: number }) => (
  <path d={`M26 ${y} q6 5 12 0`} className="fill-none stroke-forest" strokeWidth="2" strokeLinecap="round" />
)

const ART: Record<string, React.ReactNode> = {
  laundry_troll: (
    <g>
      <ellipse cx="32" cy="38" rx="20" ry="18" className="fill-accent" />
      <circle cx="14" cy="22" r="6" className="fill-accent" />
      <circle cx="50" cy="22" r="6" className="fill-accent" />
      <Eyes />
      <Smile />
      <path d="M44 48 h10 v6 h-8 q-2 0 -2 -2 Z" className="fill-peach" />
    </g>
  ),
  dust_bunny_horde: (
    <g>
      <circle cx="26" cy="38" r="15" className="fill-hairline" />
      <circle cx="40" cy="40" r="13" className="fill-surface stroke-hairline" strokeWidth="2" />
      <circle cx="32" cy="30" r="11" className="fill-hairline" />
      <Eyes y={-2} gap={10} />
      <Smile y={36} />
    </g>
  ),
  counter_goblins: (
    <g>
      <path d="M6 28 L18 24 L18 36 Z" className="fill-accent" />
      <path d="M58 28 L46 24 L46 36 Z" className="fill-accent" />
      <ellipse cx="32" cy="36" rx="16" ry="18" className="fill-accent" />
      <Eyes />
      <Smile y={42} />
      <circle cx="22" cy="52" r="2" className="fill-signal" />
      <circle cx="42" cy="54" r="2" className="fill-signal" />
    </g>
  ),
  bathroom_slime: (
    <g>
      <path d="M32 8 C48 26 54 34 54 44 a22 18 0 0 1 -44 0 C10 34 16 26 32 8 Z" className="fill-lilac" />
      <Eyes y={6} />
      <Smile y={46} />
      <circle cx="46" cy="14" r="4" className="fill-lilac-faded" />
      <circle cx="54" cy="22" r="2.5" className="fill-lilac-faded" />
    </g>
  ),
  doom_pile_dragon: (
    <g>
      <rect x="8" y="46" width="48" height="12" rx="3" className="fill-surface stroke-hairline" strokeWidth="2" />
      <rect x="12" y="40" width="40" height="8" rx="2" className="fill-peach" />
      <ellipse cx="32" cy="32" rx="18" ry="14" className="fill-lilac" />
      <path d="M22 18 l3 -8 l4 8 Z M35 18 l4 -8 l3 8 Z" className="fill-signal" />
      <Eyes y={-2} />
      <Smile y={38} />
    </g>
  ),
  toy_swarm: (
    <g>
      <rect x="8" y="30" width="20" height="20" rx="3" className="fill-signal" />
      <rect x="34" y="22" width="22" height="26" rx="3" className="fill-lilac" />
      <rect x="20" y="10" width="18" height="18" rx="3" className="fill-accent" />
      <circle cx="14" cy="38" r="2" className="fill-forest" />
      <circle cx="22" cy="38" r="2" className="fill-forest" />
      <circle cx="40" cy="32" r="2" className="fill-forest" />
      <circle cx="50" cy="32" r="2" className="fill-forest" />
      <circle cx="26" cy="18" r="2" className="fill-forest" />
      <circle cx="33" cy="18" r="2" className="fill-forest" />
    </g>
  ),
  backpack_bandits: (
    <g>
      <rect x="14" y="16" width="36" height="40" rx="10" className="fill-peach-display" />
      <rect x="20" y="40" width="24" height="12" rx="3" className="fill-peach" />
      <rect x="18" y="24" width="28" height="9" rx="4" className="fill-forest" />
      <circle cx="26" cy="28" r="2.5" className="fill-surface" />
      <circle cx="38" cy="28" r="2.5" className="fill-surface" />
      <path d="M26 14 q6 -8 12 0" className="fill-none stroke-peach-display" strokeWidth="3" strokeLinecap="round" />
    </g>
  ),
  wardrobe_wraith: (
    <g>
      <rect x="12" y="8" width="40" height="50" rx="3" className="fill-peach-display" />
      <path d="M32 8 V58" className="stroke-forest" strokeWidth="2" />
      <path d="M20 54 V30 a8 12 0 0 1 24 0 V54 l-4 -4 l-4 4 l-4 -4 l-4 4 l-4 -4 Z" className="fill-lilac-faded" />
      <Eyes y={-2} gap={10} />
      <ellipse cx="32" cy="40" rx="3" ry="3.5" className="fill-forest" />
    </g>
  ),
}

export interface MonsterArtProps extends React.SVGAttributes<SVGSVGElement> {
  monster: string | null | undefined
  label?: string
}

export function MonsterArt({ monster, label, className, ...props }: MonsterArtProps) {
  return (
    <svg
      viewBox="0 0 64 64"
      className={cn("h-16 w-16 shrink-0", className)}
      role={label ? "img" : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : true}
      {...props}
    >
      {ART[monster ?? ""] ?? ART.dust_bunny_horde}
    </svg>
  )
}
