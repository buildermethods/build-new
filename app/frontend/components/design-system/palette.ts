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
    hexLight: "#fbf7f0",
    hexDark: "#1a231e",
  },
  {
    name: "surface",
    utility: "bg-surface",
    hexLight: "#f4ede0",
    hexDark: "#232f28",
  },
  {
    name: "hairline",
    utility: "border-hairline",
    hexLight: "#e6d9c6",
    hexDark: "#35453c",
  },
];

export const TEXT: PaletteEntry[] = [
  {
    name: "ink-body",
    utility: "text-ink-body",
    hexLight: "#3f4a43",
    hexDark: "#e6e2d6",
  },
  {
    name: "ink-display",
    utility: "text-ink-display",
    hexLight: "#35453c",
    hexDark: "#f6f1e4",
  },
  {
    name: "ink-muted",
    utility: "text-ink-muted",
    hexLight: "#667062",
    hexDark: "#a9b3a4",
  },
];

export const SPLASH: PaletteEntry[] = [
  {
    name: "accent",
    utility: "bg-accent / text-accent",
    hexLight: "#5f7157",
    hexDark: "#9db094",
  },
  {
    name: "accent-faded",
    utility: "bg-accent-faded",
    hexLight: "#e8eee3",
    hexDark: "#2b3a2f",
  },
  {
    name: "accent-display",
    utility: "bg-accent-display / text-accent-display",
    hexLight: "#4a5c43",
    hexDark: "#b9cab0",
  },
  {
    name: "signal",
    utility: "bg-signal / text-signal",
    hexLight: "#f2c46d",
    hexDark: "#f2c46d",
  },
  {
    name: "signal-faded",
    utility: "bg-signal-faded",
    hexLight: "#fdf3dc",
    hexDark: "#3a3220",
  },
  {
    name: "signal-display",
    utility: "bg-signal-display / text-signal-display",
    hexLight: "#7a5710",
    hexDark: "#f7d794",
  },
  {
    name: "peach",
    utility: "bg-peach / text-peach-display",
    hexLight: "#e6c5ab",
    hexDark: "#e6c5ab",
  },
  {
    name: "lilac",
    utility: "bg-lilac / text-lilac-display",
    hexLight: "#a79abc",
    hexDark: "#a79abc",
  },
  {
    name: "forest",
    utility: "bg-forest",
    hexLight: "#35453c",
    hexDark: "#35453c",
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
