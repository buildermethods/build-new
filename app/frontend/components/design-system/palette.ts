export interface PaletteEntry {
  name: string;
  utility: string;
  hexLight: string;
  hexDark: string;
}

export const SURFACES: PaletteEntry[] = [
  {
    name: "page",
    utility: "bg-page",
    hexLight: "#fffaf7",
    hexDark: "#161a2e",
  },
  {
    name: "surface",
    utility: "bg-surface",
    hexLight: "#fff0f2",
    hexDark: "#202544",
  },
  {
    name: "hairline",
    utility: "border-hairline",
    hexLight: "#f3d6dc",
    hexDark: "#343b66",
  },
];

export const TEXT: PaletteEntry[] = [
  {
    name: "ink-body",
    utility: "text-ink-body",
    hexLight: "#3b4262",
    hexDark: "#e6e9fa",
  },
  {
    name: "ink-display",
    utility: "text-ink-display",
    hexLight: "#232a4d",
    hexDark: "#fff6f9",
  },
  {
    name: "ink-muted",
    utility: "text-ink-muted",
    hexLight: "#5a6285",
    hexDark: "#aab2d6",
  },
];

export const SPLASH: PaletteEntry[] = [
  {
    name: "accent",
    utility: "bg-accent / text-accent",
    hexLight: "#2a70b3",
    hexDark: "#7db7f2",
  },
  {
    name: "accent-faded",
    utility: "bg-accent-faded",
    hexLight: "#e1effb",
    hexDark: "#1f3558",
  },
  {
    name: "accent-display",
    utility: "bg-accent-display / text-accent-display",
    hexLight: "#1d5a98",
    hexDark: "#a7d2f8",
  },
  {
    name: "signal",
    utility: "bg-signal / text-signal",
    hexLight: "#ffd54a",
    hexDark: "#ffd54a",
  },
  {
    name: "signal-faded",
    utility: "bg-signal-faded",
    hexLight: "#fff4cc",
    hexDark: "#3d3818",
  },
  {
    name: "signal-display",
    utility: "bg-signal-display / text-signal-display",
    hexLight: "#7a5300",
    hexDark: "#ffe48a",
  },
  {
    name: "peach (rose pink)",
    utility: "bg-peach / text-peach-display",
    hexLight: "#ffb3c4",
    hexDark: "#ff9db4",
  },
  {
    name: "lilac",
    utility: "bg-lilac / text-lilac-display",
    hexLight: "#b9a6f2",
    hexDark: "#b9a6f2",
  },
  {
    name: "forest",
    utility: "bg-forest",
    hexLight: "#2a3358",
    hexDark: "#2a3358",
  },
  {
    name: "danger",
    utility: "bg-danger / text-danger",
    hexLight: "oklch(64% 0.22 25)",
    hexDark: "oklch(72% 0.20 22)",
  },
  {
    name: "danger-faded",
    utility: "bg-danger-faded",
    hexLight: "oklch(96% 0.025 25)",
    hexDark: "oklch(22% 0.05 22)",
  },
  {
    name: "danger-display",
    utility: "bg-danger-display / text-danger-display",
    hexLight: "oklch(55% 0.20 25)",
    hexDark: "oklch(82% 0.18 22)",
  },
];

export const FONTS = {
  display: "Fraunces",
  body: "Nunito",
};
