export interface PaletteEntry {
  name: string;
  utility: string;
  hexLight: string;
  hexDark: string;
}

export const SURFACES: PaletteEntry[] = [
  { name: "page", utility: "bg-page", hexLight: "#fffaf7", hexDark: "#11201f" },
  { name: "surface", utility: "bg-surface", hexLight: "#fff0f2", hexDark: "#1a2f2d" },
  { name: "hairline", utility: "border-hairline", hexLight: "#f3d6dc", hexDark: "#2b4744" },
];

export const TEXT: PaletteEntry[] = [
  { name: "ink-body", utility: "text-ink-body", hexLight: "#2c4a4c", hexDark: "#e4f3f0" },
  { name: "ink-display", utility: "text-ink-display", hexLight: "#163a3c", hexDark: "#f5fffd" },
  { name: "ink-muted", utility: "text-ink-muted", hexLight: "#55706f", hexDark: "#a3c5c0" },
  { name: "on-accent", utility: "text-on-accent", hexLight: "#0b2e2c", hexDark: "#0b2e2c" },
];

export const SPLASH: PaletteEntry[] = [
  { name: "accent", utility: "bg-accent (bright turquoise, with text-on-accent)", hexLight: "#19c3b3", hexDark: "#3fe0d0" },
  { name: "accent-strong", utility: "bg-accent-strong / border-accent-strong (meters, rings)", hexLight: "#0d9488", hexDark: "#3fe0d0" },
  { name: "accent-faded", utility: "bg-accent-faded", hexLight: "#d9f6f2", hexDark: "#14403c" },
  { name: "accent-display", utility: "text-accent-display", hexLight: "#0b6e66", hexDark: "#8ff0e6" },
  { name: "coral", utility: "bg-coral", hexLight: "#ff7f6e", hexDark: "#ff9283" },
  { name: "coral-strong", utility: "bg-coral-strong", hexLight: "#d9533f", hexDark: "#ff9283" },
  { name: "coral-faded", utility: "bg-coral-faded", hexLight: "#ffe6e0", hexDark: "#45221e" },
  { name: "coral-display", utility: "text-coral-display", hexLight: "#a63a28", hexDark: "#ffc1b6" },
  { name: "leaf", utility: "bg-leaf", hexLight: "#6fcf7a", hexDark: "#8fe48f" },
  { name: "leaf-strong", utility: "bg-leaf-strong", hexLight: "#3f9d48", hexDark: "#8fe48f" },
  { name: "leaf-faded", utility: "bg-leaf-faded", hexLight: "#e3f6e3", hexDark: "#1b3a1f" },
  { name: "leaf-display", utility: "text-leaf-display", hexLight: "#276a2f", hexDark: "#bff2bf" },
  { name: "signal", utility: "bg-signal / text-signal", hexLight: "#ffd54a", hexDark: "#ffd54a" },
  { name: "signal-faded", utility: "bg-signal-faded", hexLight: "#fff4cc", hexDark: "#3d3818" },
  { name: "signal-display", utility: "text-signal-display", hexLight: "#7a5300", hexDark: "#ffe48a" },
  { name: "peach", utility: "bg-peach (soft rose pink)", hexLight: "#ffb3c4", hexDark: "#ff9db4" },
  { name: "peach-faded", utility: "bg-peach-faded", hexLight: "#ffe6ec", hexDark: "#3d2440" },
  { name: "peach-display", utility: "text-peach-display (warm brown)", hexLight: "#8a4a2f", hexDark: "#ffc2d1" },
  { name: "lilac", utility: "bg-lilac", hexLight: "#b9a6f2", hexDark: "#b9a6f2" },
  { name: "lilac-faded", utility: "bg-lilac-faded", hexLight: "#efe9ff", hexDark: "#2e2a56" },
  { name: "lilac-display", utility: "text-lilac-display", hexLight: "#5a44b0", hexDark: "#d5c9fa" },
  { name: "forest", utility: "bg-forest / outlines", hexLight: "#1d3b3d", hexDark: "#0f2f2e" },
  { name: "danger", utility: "bg-danger / text-danger", hexLight: "oklch(64% 0.22 25)", hexDark: "oklch(72% 0.20 22)" },
  { name: "danger-faded", utility: "bg-danger-faded", hexLight: "oklch(96% 0.025 25)", hexDark: "oklch(22% 0.05 22)" },
  { name: "danger-display", utility: "bg-danger-display / text-danger-display", hexLight: "oklch(55% 0.20 25)", hexDark: "oklch(82% 0.18 22)" },
];

export const FONTS = {
  display: "Fraunces",
  body: "Nunito",
};
