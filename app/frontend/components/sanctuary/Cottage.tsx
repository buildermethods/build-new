import { DECORATION_ART } from "@/components/sanctuary/decorations"
import { cn } from "@/lib/utils"

type CottageProps = {
  /** slot => decoration key. */
  placements: Record<string, string>
  /** Decoration names by key, for the accessible description. */
  names?: Record<string, string>
  className?: string
}

const SLOT_ORDER = ["wall", "rug", "plant", "lamp"]

// One illustrated cottage room with four fixed decoration slots.
export function Cottage({ placements, names = {}, className }: CottageProps) {
  const equipped = SLOT_ORDER.map((slot) => placements[slot]).filter(Boolean)
  const label =
    equipped.length === 0
      ? "A cosy cottage room, still bare"
      : `A cosy cottage room with ${equipped.map((k) => names[k] ?? k.replace(/_/g, " ")).join(", ")}`

  return (
    <svg
      viewBox="0 0 400 300"
      role="img"
      aria-label={label}
      className={cn("h-auto w-full rounded-xl border border-hairline", className)}
    >
      <rect x="0" y="0" width="400" height="300" className="fill-surface" />
      <rect x="0" y="215" width="400" height="85" className="fill-peach-faded" />
      <rect x="0" y="210" width="400" height="6" className="fill-hairline" />
      <rect x="280" y="50" width="80" height="90" rx="6" className="fill-lilac-faded stroke-peach-display" strokeWidth="4" />
      <path d="M320 50 V140 M280 95 H360" className="stroke-peach-display" strokeWidth="3" />
      <circle cx="342" cy="72" r="7" className="fill-signal" />
      {/* soft light from the window, plus curtains */}
      <path d="M280 140 L360 140 L392 214 L248 214 Z" className="fill-signal opacity-15" />
      <path d="M272 46 q12 30 6 100 h-10 Z M368 46 q-12 30 -6 100 h10 Z" className="fill-lilac opacity-70" />
      {SLOT_ORDER.map((slot) => {
        const key = placements[slot]
        return key ? <g key={slot} data-slot={slot}>{DECORATION_ART[key]}</g> : null
      })}
    </svg>
  )
}
