// Monster art: a charming, never-scary illustration for each chore monster,
// drawn in the app's own style (soft shapes, gentle shading, big friendly eyes)
// with design tokens so it follows light and dark mode. A "sleepy" mood is
// used when a monster has been defeated: it simply nods off, nothing worse.
import * as React from "react"
import { cn } from "@/lib/utils"

export type Mood = "happy" | "sleepy"

// ---- shared face parts -------------------------------------------------------

function Face({ cx, cy, gap = 12, mood, blush = true, mouth = "smile" }: {
  cx: number
  cy: number
  gap?: number
  mood: Mood
  blush?: boolean
  mouth?: "smile" | "grin" | "none"
}) {
  const lx = cx - gap / 2
  const rx = cx + gap / 2
  return (
    <g>
      {blush && (
        <>
          <ellipse cx={lx - 4} cy={cy + 5.5} rx="3" ry="2" className="fill-peach opacity-70" />
          <ellipse cx={rx + 4} cy={cy + 5.5} rx="3" ry="2" className="fill-peach opacity-70" />
        </>
      )}
      {mood === "happy" ? (
        <>
          <circle cx={lx} cy={cy} r="4.2" className="fill-white" />
          <circle cx={rx} cy={cy} r="4.2" className="fill-white" />
          <circle cx={lx + 0.6} cy={cy + 0.8} r="2.4" className="fill-forest" />
          <circle cx={rx + 0.6} cy={cy + 0.8} r="2.4" className="fill-forest" />
          <circle cx={lx + 1.4} cy={cy - 0.2} r="0.9" className="fill-white" />
          <circle cx={rx + 1.4} cy={cy - 0.2} r="0.9" className="fill-white" />
        </>
      ) : (
        <>
          <path d={`M${lx - 3.5} ${cy} q3.5 3.5 7 0`} className="fill-none stroke-forest" strokeWidth="1.8" strokeLinecap="round" />
          <path d={`M${rx - 3.5} ${cy} q3.5 3.5 7 0`} className="fill-none stroke-forest" strokeWidth="1.8" strokeLinecap="round" />
        </>
      )}
      {mouth === "smile" && (
        <path
          d={mood === "happy" ? `M${cx - 4} ${cy + 7} q4 4 8 0` : `M${cx - 2} ${cy + 8} q2 1.5 4 0`}
          className="fill-none stroke-forest"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
      )}
      {mouth === "grin" && (
        <>
          <path d={`M${cx - 5} ${cy + 6} q5 6 10 0 z`} className="fill-forest" />
          <path d={`M${cx - 3} ${cy + 6.2} l1.5 2 l1.5 -2 M${cx + 0.5} ${cy + 6.2} l1.5 2 l1.5 -2`} className="fill-surface stroke-surface" strokeWidth="0.8" />
        </>
      )}
    </g>
  )
}

const Zzz = ({ x, y }: { x: number; y: number }) => (
  <g className="fill-lilac-display">
    <text x={x} y={y} fontSize="7" fontWeight="700" fontFamily="sans-serif">z</text>
    <text x={x + 5} y={y - 6} fontSize="5.5" fontWeight="700" fontFamily="sans-serif">z</text>
  </g>
)

// ---- the monsters --------------------------------------------------------------

const ART: Record<string, (mood: Mood) => React.ReactNode> = {
  laundry_troll: (mood) => (
    <g>
      <ellipse cx="32" cy="58" rx="19" ry="3" className="fill-forest opacity-10" />
      <circle cx="14.5" cy="26" r="5.5" className="fill-accent" />
      <circle cx="49.5" cy="26" r="5.5" className="fill-accent" />
      <circle cx="14.5" cy="26" r="2.6" className="fill-accent-display opacity-60" />
      <circle cx="49.5" cy="26" r="2.6" className="fill-accent-display opacity-60" />
      <path d="M26 11 q2 -6 4 -1 q2 -6 4 -1 q2 -4 4 2" className="fill-forest" />
      <ellipse cx="32" cy="38" rx="21" ry="19" className="fill-accent" />
      <path d="M12 44 q20 22 40 0 q-2 10 -20 12 q-18 -2 -20 -12 z" className="fill-accent-display opacity-40" />
      <ellipse cx="32" cy="46" rx="11" ry="9" className="fill-accent-faded opacity-70" />
      <ellipse cx="13" cy="46" rx="4.5" ry="6" className="fill-accent" />
      <path d="M52 40 l7 -1 q4 0 3 5 l-3 9 q-1 3 -4 2 z" className="fill-peach" />
      <path d="M53.5 46 h6 M54 50 h5" className="stroke-lilac" strokeWidth="2" />
      <Face cx={32} cy={31} gap={13} mood={mood} />
      {mood === "sleepy" && <Zzz x={46} y={14} />}
    </g>
  ),
  dust_bunny_horde: (mood) => (
    <g>
      <ellipse cx="32" cy="58" rx="20" ry="3" className="fill-forest opacity-10" />
      <ellipse cx="22" cy="16" rx="4.5" ry="11" transform="rotate(-12 22 16)" className="fill-hairline" />
      <ellipse cx="42" cy="16" rx="4.5" ry="11" transform="rotate(12 42 16)" className="fill-hairline" />
      <ellipse cx="22" cy="17" rx="2" ry="7.5" transform="rotate(-12 22 17)" className="fill-peach opacity-80" />
      <ellipse cx="42" cy="17" rx="2" ry="7.5" transform="rotate(12 42 17)" className="fill-peach opacity-80" />
      <circle cx="19" cy="45" r="13" className="fill-hairline" />
      <circle cx="45" cy="46" r="12" className="fill-hairline" />
      <circle cx="32" cy="36" r="17" className="fill-hairline" />
      <circle cx="24" cy="28" r="7" className="fill-surface opacity-60" />
      <circle cx="19" cy="48" r="6" className="fill-surface opacity-40" />
      <Face cx={32} cy={35} gap={11} mood={mood} mouth="none" />
      <ellipse cx="32" cy="41.5" rx="2.2" ry="1.6" className="fill-peach-display" />
      <path d="M32 43 v2.5 M32 45.5 q-2.5 2 -4.5 0 M32 45.5 q2.5 2 4.5 0" className="fill-none stroke-forest" strokeWidth="1.4" strokeLinecap="round" />
      <circle cx="8" cy="30" r="1.6" className="fill-hairline" />
      <circle cx="55" cy="24" r="1.3" className="fill-hairline" />
      <circle cx="53" cy="56" r="1.8" className="fill-hairline" />
      {mood === "sleepy" && <Zzz x={46} y={12} />}
    </g>
  ),
  counter_goblins: (mood) => (
    <g>
      <ellipse cx="32" cy="59" rx="20" ry="3" className="fill-forest opacity-10" />
      <ellipse cx="13" cy="42" rx="9" ry="10" className="fill-accent-display" />
      <path d="M5 38 l-5 -6 l8 2 z" className="fill-accent-display" />
      <ellipse cx="51" cy="42" rx="9" ry="10" className="fill-accent-display" />
      <path d="M59 38 l5 -6 l-8 2 z" className="fill-accent-display" />
      <path d="M2 30 L19 22 L19 38 Z" className="fill-accent" />
      <path d="M62 30 L45 22 L45 38 Z" className="fill-accent" />
      <path d="M6 30 L17 25 L17 34 Z" className="fill-lilac-faded opacity-80" />
      <path d="M58 30 L47 25 L47 34 Z" className="fill-lilac-faded opacity-80" />
      <ellipse cx="32" cy="38" rx="17" ry="19" className="fill-accent" />
      <path d="M16 44 q16 20 32 0 q-3 11 -16 12 q-13 -1 -16 -12 z" className="fill-accent-display opacity-40" />
      <path d="M22 21 q10 -9 20 0 l-2 4 q-8 -4 -16 0 z" className="fill-forest" />
      <path d="M40 19 q5 -9 9 -7 q-3 3 -4 8 z" className="fill-signal" />
      <Face cx={32} cy={34} gap={12} mood={mood} mouth="grin" />
      <circle cx="46" cy="55" r="2.6" className="fill-peach" />
      <circle cx="20" cy="57" r="1.8" className="fill-peach" />
      {mood === "sleepy" && <Zzz x={48} y={12} />}
    </g>
  ),
  bathroom_slime: (mood) => (
    <g>
      <ellipse cx="32" cy="58" rx="24" ry="4.5" className="fill-lilac opacity-45" />
      <path d="M32 5 C48 24 56 33 56 45 a24 15 0 0 1 -48 0 C8 33 16 24 32 5 Z" className="fill-lilac" />
      <path d="M12 47 q20 13 40 0 q-3 9 -20 10 q-17 -1 -20 -10 z" className="fill-lilac-display opacity-45" />
      <path d="M21 33 C22 24 26 18 30 13" className="fill-none stroke-lilac-faded" strokeWidth="3.2" strokeLinecap="round" />
      <circle cx="21" cy="40" r="1.8" className="fill-lilac-faded" />
      <Face cx={33} cy={39} gap={13} mood={mood} />
      <circle cx="52" cy="12" r="4.2" className="fill-lilac-faded stroke-lilac" strokeWidth="1" />
      <circle cx="58" cy="22" r="2.6" className="fill-lilac-faded stroke-lilac" strokeWidth="1" />
      <circle cx="9" cy="22" r="2.2" className="fill-lilac-faded stroke-lilac" strokeWidth="1" />
      {mood === "sleepy" && <Zzz x={47} y={10} />}
    </g>
  ),
  doom_pile_dragon: (mood) => (
    <g>
      <ellipse cx="32" cy="60" rx="26" ry="3" className="fill-forest opacity-10" />
      <rect x="6" y="48" width="52" height="11" rx="3" className="fill-surface stroke-hairline" strokeWidth="1.5" />
      <rect x="10" y="43" width="44" height="7" rx="2" className="fill-peach" />
      <rect x="14" y="39" width="36" height="6" rx="2" className="fill-surface stroke-hairline" strokeWidth="1.2" />
      <path d="M12 53 h40 M12 56 h28" className="stroke-hairline" strokeWidth="1.2" />
      <path d="M50 44 q10 -2 9 -11 q-2 -6 -7 -4 q3 4 -2 8 q-3 3 0 7 z" className="fill-lilac" />
      <path d="M59 32 l4 -3 l-1 6 z" className="fill-signal" />
      <path d="M14 36 L2 22 q10 -3 16 6 z" className="fill-lilac-display opacity-80" />
      <path d="M50 36 L62 22 q-10 -3 -16 6 z" className="fill-lilac-display opacity-80" />
      <ellipse cx="32" cy="32" rx="19" ry="15" className="fill-lilac" />
      <ellipse cx="32" cy="37" rx="11" ry="9" className="fill-lilac-faded" />
      <path d="M22 18 l2 -8 l4 7 z M31 16 l3 -9 l3 9 z M40 18 l3 -7 l2 8 z" className="fill-signal" />
      <path d="M14 38 q-2 6 4 5 z" className="fill-lilac-display opacity-60" />
      <Face cx={32} cy={28} gap={12} mood={mood} />
      <ellipse cx="29" cy="35" rx="1" ry="1.4" className="fill-lilac-display" />
      <ellipse cx="35" cy="35" rx="1" ry="1.4" className="fill-lilac-display" />
      {mood === "sleepy" && <Zzz x={48} y={14} />}
    </g>
  ),
  toy_swarm: (mood) => (
    <g>
      <ellipse cx="32" cy="59" rx="26" ry="3" className="fill-forest opacity-10" />
      <rect x="5" y="31" width="22" height="22" rx="4" className="fill-signal" />
      <rect x="5" y="46" width="22" height="7" rx="3" className="fill-peach-display opacity-35" />
      <rect x="36" y="22" width="24" height="31" rx="4" className="fill-lilac" />
      <rect x="36" y="46" width="24" height="7" rx="3" className="fill-lilac-display opacity-40" />
      <rect x="17" y="6" width="22" height="22" rx="4" className="fill-accent" />
      <rect x="17" y="21" width="22" height="7" rx="3" className="fill-accent-display opacity-40" />
      <path d="M48 41 l1.2 2.6 l2.8 0.3 l-2.1 1.9 l0.6 2.8 l-2.5 -1.4 l-2.5 1.4 l0.6 -2.8 l-2.1 -1.9 l2.8 -0.3 z" className="fill-signal" />
      <Face cx={16} cy={39} gap={9} mood={mood} blush={false} mouth="none" />
      <path d="M13 45 q3 3 6 0" className="fill-none stroke-forest" strokeWidth="1.6" strokeLinecap="round" />
      <Face cx={48} cy={30} gap={10} mood={mood} blush={false} mouth="none" />
      <path d="M45 36 q3 3 6 0" className="fill-none stroke-forest" strokeWidth="1.6" strokeLinecap="round" />
      <Face cx={28} cy={14} gap={9} mood={mood} blush={false} mouth="none" />
      <path d="M25 20 q3 3 6 0" className="fill-none stroke-forest" strokeWidth="1.6" strokeLinecap="round" />
      <rect x="9" y="53" width="5" height="4" rx="1.5" className="fill-forest" />
      <rect x="18" y="53" width="5" height="4" rx="1.5" className="fill-forest" />
      <rect x="40" y="53" width="5" height="4" rx="1.5" className="fill-forest" />
      <rect x="51" y="53" width="5" height="4" rx="1.5" className="fill-forest" />
      {mood === "sleepy" && <Zzz x={48} y={14} />}
    </g>
  ),
  backpack_bandits: (mood) => (
    <g>
      <ellipse cx="32" cy="60" rx="20" ry="3" className="fill-forest opacity-10" />
      <path d="M24 14 q8 -10 16 0" className="fill-none stroke-peach-display" strokeWidth="4" strokeLinecap="round" />
      <rect x="12" y="14" width="40" height="44" rx="13" className="fill-peach-display" />
      <path d="M12 44 q20 14 40 0 v4 q0 10 -13 10 h-14 q-13 0 -13 -10 z" className="fill-forest opacity-25" />
      <rect x="19" y="40" width="26" height="14" rx="5" className="fill-peach" />
      <rect x="29" y="44" width="6" height="5" rx="1.5" className="fill-signal" />
      <rect x="14" y="24" width="36" height="10" rx="5" className="fill-forest" />
      <ellipse cx="25" cy="29" rx="4" ry="3.2" className="fill-surface" />
      <ellipse cx="39" cy="29" rx="4" ry="3.2" className="fill-surface" />
      <circle cx="26" cy="29.4" r="1.9" className="fill-forest" />
      <circle cx="40" cy="29.4" r="1.9" className="fill-forest" />
      {mood === "sleepy" && (
        <>
          <path d="M21 29 q4 3 8 0 M35 29 q4 3 8 0" className="fill-none stroke-surface" strokeWidth="2" strokeLinecap="round" />
          <Zzz x={46} y={14} />
        </>
      )}
      <path d="M28 38 q4 3 8 0" className="fill-none stroke-forest" strokeWidth="1.8" strokeLinecap="round" />
      <ellipse cx="11" cy="46" rx="3.6" ry="5" className="fill-peach-display" />
      <ellipse cx="53" cy="46" rx="3.6" ry="5" className="fill-peach-display" />
      <path d="M52 50 l8 -2 q3 0 2 4 l-3 5 z" className="fill-lilac" />
    </g>
  ),
  wardrobe_wraith: (mood) => (
    <g>
      <ellipse cx="32" cy="60" rx="22" ry="3" className="fill-forest opacity-10" />
      <rect x="9" y="5" width="46" height="54" rx="4" className="fill-peach-display" />
      <rect x="14" y="10" width="36" height="44" rx="2" className="fill-forest" />
      <path d="M14 10 L6 14 V58 L14 54 Z" className="fill-peach" />
      <path d="M50 10 L58 14 V58 L50 54 Z" className="fill-peach" />
      <circle cx="9" cy="34" r="1.6" className="fill-signal" />
      <circle cx="55" cy="34" r="1.6" className="fill-signal" />
      <path d="M32 12 v4 q0 2 -3 3 M28 19 l8 0" className="fill-none stroke-hairline" strokeWidth="1.4" strokeLinecap="round" />
      <rect x="16" y="18" width="6" height="14" rx="1.5" className="fill-accent" />
      <rect x="42" y="18" width="6" height="14" rx="1.5" className="fill-signal" />
      <path d="M22 54 V32 a10 15 0 0 1 20 0 V54 l-3.3 -4.5 l-3.3 4.5 l-3.4 -4.5 l-3.3 4.5 l-3.3 -4.5 z" className="fill-lilac-faded" />
      <path d="M24 34 a8 12 0 0 1 3 -9" className="fill-none stroke-surface" strokeWidth="2" strokeLinecap="round" />
      <Face cx={32} cy={33} gap={9} mood={mood} blush={false} mouth="none" />
      <ellipse cx="32" cy="41" rx={mood === "happy" ? 2.4 : 1.6} ry={mood === "happy" ? 2.8 : 1.2} className="fill-forest" />
      {mood === "sleepy" && <Zzz x={46} y={12} />}
    </g>
  ),
}

export interface MonsterArtProps extends React.SVGAttributes<SVGSVGElement> {
  monster: string | null | undefined
  label?: string
  /** "sleepy" is the friendly after-defeat pose. */
  mood?: Mood
}

export function MonsterArt({ monster, label, mood = "happy", className, ...props }: MonsterArtProps) {
  const draw = ART[monster ?? ""] ?? ART.dust_bunny_horde
  return (
    <svg
      viewBox="0 0 64 64"
      className={cn("h-16 w-16 shrink-0", className)}
      role={label ? "img" : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : true}
      {...props}
    >
      {draw(mood)}
    </svg>
  )
}
