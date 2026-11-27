import type { ReactNode } from "react"

// Placeholder-quality inline SVG art for each decoration, drawn in the
// cottage's 400x300 coordinate space and coloured with design tokens so it
// follows light/dark mode. Swap these for real illustrations later; only the
// keys in config/game/decorations.yml need to match.
export const DECORATION_ART: Record<string, ReactNode> = {
  woven_rug: (
    <g>
      <ellipse cx="200" cy="250" rx="95" ry="22" className="fill-peach" />
      <ellipse cx="200" cy="250" rx="70" ry="15" className="fill-surface" />
      <ellipse cx="200" cy="250" rx="45" ry="9" className="fill-peach" />
    </g>
  ),
  moss_rug: (
    <g>
      <ellipse cx="200" cy="250" rx="95" ry="22" className="fill-accent" />
      <ellipse cx="200" cy="250" rx="60" ry="13" className="fill-accent-faded" />
    </g>
  ),
  starry_rug: (
    <g>
      <ellipse cx="200" cy="250" rx="95" ry="22" className="fill-lilac" />
      <circle cx="160" cy="248" r="3" className="fill-signal" />
      <circle cx="200" cy="244" r="3" className="fill-signal" />
      <circle cx="240" cy="252" r="3" className="fill-signal" />
    </g>
  ),
  fern_pot: (
    <g>
      <path d="M52 232 h36 l-5 28 h-26 z" className="fill-peach-display" />
      <path d="M70 232 C50 200 40 190 38 175 C58 185 66 205 70 232 Z" className="fill-accent" />
      <path d="M70 232 C90 200 100 190 102 175 C82 185 74 205 70 232 Z" className="fill-accent" />
      <path d="M70 232 C68 195 70 180 70 165 C76 185 76 205 70 232 Z" className="fill-accent-display" />
    </g>
  ),
  sunny_succulent: (
    <g>
      <path d="M52 238 h36 l-5 22 h-26 z" className="fill-peach-display" />
      <ellipse cx="70" cy="226" rx="20" ry="14" className="fill-accent" />
      <ellipse cx="70" cy="222" rx="10" ry="9" className="fill-accent-display" />
      <circle cx="70" cy="210" r="4" className="fill-signal" />
    </g>
  ),
  lemon_tree: (
    <g>
      <path d="M52 238 h36 l-5 22 h-26 z" className="fill-peach-display" />
      <rect x="67" y="190" width="6" height="48" className="fill-peach-display" />
      <circle cx="70" cy="170" r="30" className="fill-accent" />
      <circle cx="58" cy="168" r="5" className="fill-signal" />
      <circle cx="80" cy="178" r="5" className="fill-signal" />
      <circle cx="72" cy="156" r="5" className="fill-signal" />
    </g>
  ),
  table_lamp: (
    <g>
      <rect x="322" y="214" width="26" height="6" rx="2" className="fill-forest" />
      <rect x="333" y="192" width="4" height="24" className="fill-forest" />
      <path d="M318 192 L352 192 L344 166 L326 166 Z" className="fill-signal" />
    </g>
  ),
  lantern: (
    <g>
      <rect x="326" y="214" width="22" height="6" rx="2" className="fill-forest" />
      <rect x="329" y="176" width="16" height="38" rx="3" className="fill-signal-faded stroke-forest" strokeWidth="2" />
      <circle cx="337" cy="195" r="6" className="fill-signal" />
      <path d="M331 176 q6 -12 12 0" className="stroke-forest" strokeWidth="2" fill="none" />
    </g>
  ),
  firefly_lamp: (
    <g>
      <rect x="326" y="214" width="22" height="6" rx="2" className="fill-forest" />
      <rect x="326" y="180" width="22" height="34" rx="8" className="fill-lilac-faded stroke-lilac" strokeWidth="2" />
      <circle cx="334" cy="196" r="3" className="fill-signal" />
      <circle cx="342" cy="204" r="3" className="fill-signal" />
      <circle cx="338" cy="188" r="2.5" className="fill-signal" />
    </g>
  ),
  meadow_frame: (
    <g>
      <rect x="150" y="48" width="100" height="64" rx="4" className="fill-peach-display" />
      <rect x="158" y="56" width="84" height="48" className="fill-accent-faded" />
      <path d="M158 96 q20 -22 42 -4 q22 -18 42 4 V104 H158 Z" className="fill-accent" />
      <circle cx="224" cy="70" r="7" className="fill-signal" />
    </g>
  ),
  moon_tapestry: (
    <g>
      <rect x="160" y="40" width="80" height="84" className="fill-lilac" />
      <path d="M160 124 l10 -10 l10 10 l10 -10 l10 10 l10 -10 l10 10 l10 -10 l10 10 Z" className="fill-lilac" />
      <circle cx="200" cy="76" r="18" className="fill-signal" />
      <circle cx="209" cy="71" r="16" className="fill-lilac" />
    </g>
  ),
  curio_shelf: (
    <g>
      <rect x="140" y="92" width="120" height="8" rx="2" className="fill-peach-display" />
      <rect x="152" y="68" width="18" height="24" rx="3" className="fill-lilac" />
      <circle cx="205" cy="82" r="10" className="fill-signal" />
      <rect x="228" y="72" width="16" height="20" rx="3" className="fill-accent" />
    </g>
  ),
  checkered_mat: (
    <g>
      <rect x="105" y="236" width="190" height="32" rx="4" className="fill-surface stroke-hairline" strokeWidth="2" />
      {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((i) => (
        <rect key={i} x={105 + i * 15.8} y={i % 2 ? 236 : 252} width="15.8" height="16" className="fill-accent" />
      ))}
    </g>
  ),
  herb_pots: (
    <g>
      {[44, 66, 88].map((x, i) => (
        <g key={x}>
          <path d={`M${x} 244 h16 l-3 16 h-10 z`} className="fill-peach-display" />
          <path d={`M${x + 8} 244 q${i % 2 ? -8 : 8} -14 0 -26 q${i % 2 ? 8 : -8} 12 0 26`} className="fill-accent" />
        </g>
      ))}
    </g>
  ),
  pendant_light: (
    <g>
      <path d="M335 0 V150" className="stroke-forest" strokeWidth="2" />
      <path d="M318 172 q17 -30 34 0 Z" className="fill-peach-display" />
      <circle cx="335" cy="174" r="6" className="fill-signal" />
    </g>
  ),
  tea_towel_shelf: (
    <g>
      <rect x="140" y="92" width="120" height="7" rx="2" className="fill-peach-display" />
      <rect x="156" y="99" width="22" height="34" className="fill-surface stroke-hairline" strokeWidth="2" />
      <rect x="156" y="106" width="22" height="5" className="fill-accent" />
      <rect x="156" y="116" width="22" height="5" className="fill-accent" />
      <circle cx="214" cy="80" r="11" className="fill-lilac" />
      <rect x="232" y="64" width="16" height="28" rx="3" className="fill-signal" />
    </g>
  ),
  quilt_rug: (
    <g>
      {[0, 1, 2, 3, 4, 5].map((i) => (
        <rect
          key={i}
          x={110 + (i % 3) * 60}
          y={238 + Math.floor(i / 3) * 16}
          width="60"
          height="16"
          className={["fill-lilac", "fill-peach", "fill-accent", "fill-signal", "fill-accent", "fill-lilac"][i]}
        />
      ))}
    </g>
  ),
  sleepy_cactus: (
    <g>
      <path d="M52 238 h36 l-5 22 h-26 z" className="fill-peach-display" />
      <rect x="62" y="196" width="16" height="44" rx="8" className="fill-accent" />
      <path d="M62 214 h-6 q-6 0 -6 -8 v-8 h6 v8 h6 z M78 220 h6 q6 0 6 -8 v-8 h-6 v8 h-6 z" className="fill-accent" />
      <path d="M66 204 q4 3 8 0" className="fill-none stroke-forest" strokeWidth="1.5" />
    </g>
  ),
  bedside_lamp: (
    <g>
      <rect x="322" y="214" width="26" height="6" rx="2" className="fill-forest" />
      <rect x="333" y="200" width="4" height="16" className="fill-forest" />
      <circle cx="335" cy="186" r="15" className="fill-signal" />
      <circle cx="341" cy="182" r="13" className="fill-signal-faded" />
    </g>
  ),
  star_poster: (
    <g>
      <rect x="160" y="44" width="80" height="76" rx="3" className="fill-forest" />
      {[[175, 60], [200, 78], [222, 58], [188, 100], [226, 102], [205, 55]].map(([x, y]) => (
        <circle key={`${x}-${y}`} cx={x} cy={y} r="2.5" className="fill-signal" />
      ))}
      <path d="M182 108 q18 -22 40 0" className="fill-none stroke-lilac" strokeWidth="3" strokeLinecap="round" />
    </g>
  ),
  stepping_stones: (
    <g>
      {[[120, 252], [160, 244], [204, 254], [250, 246], [292, 254]].map(([x, y]) => (
        <ellipse key={x} cx={x} cy={y} rx="20" ry="8" className="fill-surface stroke-hairline" strokeWidth="2" />
      ))}
    </g>
  ),
  flower_boxes: (
    <g>
      <rect x="36" y="238" width="70" height="22" rx="3" className="fill-peach-display" />
      {[48, 66, 84, 98].map((x, i) => (
        <g key={x}>
          <rect x={x} y="222" width="3" height="18" className="fill-accent-display" />
          <circle cx={x + 1.5} cy="218" r="7" className={["fill-lilac", "fill-peach", "fill-signal", "fill-lilac"][i]} />
        </g>
      ))}
    </g>
  ),
  fairy_lights: (
    <g>
      <path d="M20 60 q90 40 180 0 t180 0" className="fill-none stroke-forest" strokeWidth="2" />
      {[44, 84, 124, 164, 204, 244, 284, 324, 364].map((x, i) => (
        <circle key={x} cx={x} cy={i % 2 ? 76 : 70} r="5" className={["fill-signal", "fill-lilac", "fill-peach"][i % 3]} />
      ))}
    </g>
  ),
  birdhouse: (
    <g>
      <rect x="196" y="100" width="8" height="40" className="fill-peach-display" />
      <rect x="176" y="68" width="48" height="38" rx="3" className="fill-peach" />
      <path d="M170 70 L200 46 L230 70 Z" className="fill-peach-display" />
      <circle cx="200" cy="88" r="7" className="fill-forest" />
    </g>
  ),
}
