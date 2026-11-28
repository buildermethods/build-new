import { cn } from "@/lib/utils"

export const BRAND = "Nest Quest"
export const TAGLINE = "Defeat chaos. Build calm."

// The Nest Quest mascot: a cheeky yellow chick peeking out of a woven nest in a
// little aqua explorer cap with a coral feather. Brand colours are fixed (they
// match public/icon.svg) so the mark looks the same in every theme.
export function LogoMark({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 512 512" aria-hidden="true" className={cn("shrink-0", className)}>
      <rect width="512" height="512" rx="112" fill="#19d3e3"/>
      <circle cx="256" cy="256" r="208" fill="#dff7fa" opacity=".4"/>
      <path d="M100 92l10 30 30 10-30 10-10 30-10-30-30-10 30-10z" fill="#ffc933"/>
      <path d="M436 196l6 18 18 6-18 6-6 18-6-18-18-6 18-6z" fill="#fffdf9"/>
      <ellipse cx="136" cy="304" rx="34" ry="48" transform="rotate(-18 136 304)" fill="#ffc933"/>
      <ellipse cx="376" cy="304" rx="34" ry="48" transform="rotate(18 376 304)" fill="#ffc933"/>
      <ellipse cx="136" cy="310" rx="18" ry="30" transform="rotate(-18 136 310)" fill="#ffbf9b" opacity=".55"/>
      <ellipse cx="376" cy="310" rx="18" ry="30" transform="rotate(18 376 310)" fill="#ffbf9b" opacity=".55"/>
      <circle cx="256" cy="264" r="128" fill="#ffc933"/>
      <ellipse cx="256" cy="316" rx="80" ry="56" fill="#fffdf9" opacity=".3"/>
      <path d="M146 204C146 122 198 84 256 84s110 38 110 120z" fill="#0897ad"/>
      <path d="M128 208q128-34 256 0q-12 26-128 22q-116 4-128-22z" fill="#0a6678"/>
      <path d="M148 186q108-30 216 0l2 20q-110-30-220 0z" fill="#fbf6ec"/>
      <path d="M256 112l6 14 15 2-11 10 3 15-13-8-13 8 3-15-11-10 15-2z" fill="#ffc933"/>
      <path d="M340 170C374 128 394 98 418 62c4 48-18 88-66 128z" fill="#ff6b57"/>
      <path d="M352 178C380 140 398 108 414 76" fill="none" stroke="#d9442f" strokeWidth="5" strokeLinecap="round"/>
      <circle cx="212" cy="252" r="16" fill="#0c3440"/>
      <circle cx="300" cy="252" r="16" fill="#0c3440"/>
      <circle cx="218" cy="245" r="5.5" fill="#fffdf9"/>
      <circle cx="306" cy="245" r="5.5" fill="#fffdf9"/>
      <ellipse cx="174" cy="290" rx="24" ry="15" fill="#ff6b57" opacity=".5"/>
      <ellipse cx="338" cy="290" rx="24" ry="15" fill="#ff6b57" opacity=".5"/>
      <path d="M238 278q18-10 36 0q-4 24-18 28q-14-4-18-28z" fill="#ff6b57"/>
      <path d="M244 286q12-6 24 0" fill="none" stroke="#d9442f" strokeWidth="3" strokeLinecap="round" opacity=".7"/>
      <path d="M78 330c8 96 86 148 178 148s170-52 178-148c-46 46-106 62-178 62S124 376 78 330z" fill="#8a4a2f"/>
      <path d="M96 340c56 34 108 44 160 44s104-10 160-44" fill="none" stroke="#ffbf9b" strokeWidth="12" strokeLinecap="round"/>
      <path d="M120 388c44 22 90 30 136 30s92-8 136-30" fill="none" stroke="#ffbf9b" strokeWidth="10" strokeLinecap="round" opacity=".8"/>
      <path d="M160 432c30 12 62 18 96 18s66-6 96-18" fill="none" stroke="#ffbf9b" strokeWidth="9" strokeLinecap="round" opacity=".6"/>
      <path d="M400 338c34-8 64 8 70 40-34 6-62-10-70-40z" fill="#62c46a"/>
      <path d="M406 346c20 6 38 18 52 28" fill="none" stroke="#0c3440" strokeWidth="4" strokeLinecap="round" opacity=".45"/>
    </svg>
  )
}

const SIZES = {
  sm: { icon: "h-8 w-8", text: "text-xl", gap: "gap-2" },
  md: { icon: "h-10 w-10", text: "text-xl", gap: "gap-2" },
  lg: { icon: "h-20 w-20", text: "text-4xl", gap: "gap-3" },
  xl: { icon: "h-32 w-32", text: "text-6xl", gap: "gap-5" },
} as const

export interface LogoProps {
  size?: keyof typeof SIZES
  /** Stack the mark above the wordmark (for sign-in and welcome screens). */
  stacked?: boolean
  /** Show the tagline under the wordmark. */
  tagline?: boolean
  /** Mark only (e.g. a collapsed sidebar). The brand name stays available to screen readers. */
  iconOnly?: boolean
  className?: string
}

// Logo lockup: the mascot mark with a chunky rounded two-tone wordmark.
export function Logo({ size = "md", stacked = false, tagline = false, iconOnly = false, className }: LogoProps) {
  const s = SIZES[size]
  return (
    <span className={cn("inline-flex items-center", stacked ? "flex-col text-center" : "", s.gap, className)}>
      <LogoMark className={s.icon} />
      {iconOnly ? (
        <span className="sr-only">{BRAND}</span>
      ) : (
        <span className="flex flex-col leading-none">
          <span className={cn("whitespace-nowrap font-brand font-bold text-ink-display", s.text)}>
            Nest <span className="text-accent-display">Quest</span>
          </span>
          {tagline && <span className="mt-2 text-sm font-semibold text-ink-muted">{TAGLINE}</span>}
        </span>
      )}
    </span>
  )
}
