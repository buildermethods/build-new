import { DECORATION_ART } from "@/components/sanctuary/decorations"
import { cn } from "@/lib/utils"

type CottageProps = {
  /** slot => decoration key, for this room. */
  placements: Record<string, string>
  /** Which room to draw. */
  room?: string
  /** Decoration names by key, for the accessible description. */
  names?: Record<string, string>
  className?: string
}

const SLOT_ORDER = ["wall", "rug", "plant", "lamp"]

const ROOM_NAMES: Record<string, string> = {
  living_room: "living room",
  kitchen: "kitchen",
  bedroom: "bedroom",
  garden: "garden",
}

// Each room is an illustrated backdrop with the same four fixed decoration slots.
function Backdrop({ room }: { room: string }) {
  switch (room) {
    case "kitchen":
      return (
        <g>
          <rect x="0" y="0" width="400" height="300" className="fill-accent-faded" />
          {Array.from({ length: 10 }, (_, i) => (
            <path key={i} d={`M${i * 40} 0 V215`} className="stroke-hairline" strokeWidth="1.5" />
          ))}
          {Array.from({ length: 6 }, (_, i) => (
            <path key={i} d={`M0 ${i * 40} H400`} className="stroke-hairline" strokeWidth="1.5" />
          ))}
          <rect x="0" y="215" width="400" height="85" className="fill-peach-faded" />
          <rect x="0" y="210" width="400" height="6" className="fill-hairline" />
          <rect x="14" y="14" width="110" height="52" rx="4" className="fill-peach-display" />
          <path d="M69 14 V66" className="stroke-forest" strokeWidth="2" />
          <rect x="280" y="50" width="80" height="90" rx="6" className="fill-lilac-faded stroke-peach-display" strokeWidth="4" />
          <path d="M320 50 V140 M280 95 H360" className="stroke-peach-display" strokeWidth="3" />
        </g>
      )
    case "bedroom":
      return (
        <g>
          <rect x="0" y="0" width="400" height="300" className="fill-lilac-faded" />
          <rect x="0" y="215" width="400" height="85" className="fill-peach-faded" />
          <rect x="0" y="210" width="400" height="6" className="fill-hairline" />
          <rect x="120" y="132" width="160" height="82" rx="6" className="fill-peach-display" />
          <rect x="128" y="150" width="144" height="56" rx="5" className="fill-accent" />
          <rect x="140" y="140" width="46" height="20" rx="8" className="fill-surface" />
          <rect x="214" y="140" width="46" height="20" rx="8" className="fill-surface" />
          <rect x="280" y="40" width="80" height="90" rx="6" className="fill-surface stroke-peach-display" strokeWidth="4" />
          <path d="M270 36 q14 40 8 100 h-10 Z M370 36 q-14 40 -8 100 h10 Z" className="fill-lilac opacity-70" />
        </g>
      )
    case "garden":
      return (
        <g>
          <rect x="0" y="0" width="400" height="300" className="fill-lilac-faded" />
          <circle cx="332" cy="52" r="26" className="fill-signal" />
          <path d="M0 150 q100 -50 200 -10 t200 -20 V215 H0 Z" className="fill-accent-faded" />
          {Array.from({ length: 14 }, (_, i) => (
            <rect key={i} x={6 + i * 29} y="132" width="20" height="84" rx="3" className="fill-peach" />
          ))}
          <rect x="0" y="150" width="400" height="8" className="fill-peach-display" />
          <rect x="0" y="215" width="400" height="85" className="fill-accent-faded" />
          <rect x="0" y="210" width="400" height="6" className="fill-accent" />
        </g>
      )
    default:
      return (
        <g>
          <rect x="0" y="0" width="400" height="300" className="fill-surface" />
          <rect x="0" y="215" width="400" height="85" className="fill-peach-faded" />
          <rect x="0" y="210" width="400" height="6" className="fill-hairline" />
          <rect x="280" y="50" width="80" height="90" rx="6" className="fill-lilac-faded stroke-peach-display" strokeWidth="4" />
          <path d="M320 50 V140 M280 95 H360" className="stroke-peach-display" strokeWidth="3" />
          <circle cx="342" cy="72" r="7" className="fill-signal" />
          {/* soft light from the window, plus curtains */}
          <path d="M280 140 L360 140 L392 214 L248 214 Z" className="fill-signal opacity-15" />
          <path d="M272 46 q12 30 6 100 h-10 Z M368 46 q-12 30 -6 100 h10 Z" className="fill-lilac opacity-70" />
        </g>
      )
  }
}

// One illustrated room with four fixed decoration slots.
export function Cottage({ placements, room = "living_room", names = {}, className }: CottageProps) {
  const equipped = SLOT_ORDER.map((slot) => placements[slot]).filter(Boolean)
  const where = ROOM_NAMES[room] ?? "room"
  const label =
    equipped.length === 0
      ? `A cosy cottage ${where}, still bare`
      : `A cosy cottage ${where} with ${equipped.map((k) => names[k] ?? k.replace(/_/g, " ")).join(", ")}`

  return (
    <svg
      viewBox="0 0 400 300"
      role="img"
      aria-label={label}
      className={cn("h-auto w-full rounded-xl border border-hairline", className)}
    >
      <Backdrop room={room} />
      {SLOT_ORDER.map((slot) => {
        const key = placements[slot]
        return key ? <g key={slot} data-slot={slot}>{DECORATION_ART[key]}</g> : null
      })}
    </svg>
  )
}
