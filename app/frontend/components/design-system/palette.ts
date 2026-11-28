export interface PaletteEntry {
  name: string;
  utility: string;
  hexLight: string;
  hexDark: string;
}

export const SURFACES: PaletteEntry[] = [
  { name: "page", utility: "bg-page", hexLight: "#fffdf9", hexDark: "#0b2229" },
  { name: "surface", utility: "bg-surface", hexLight: "#fbf6ec", hexDark: "#123039" },
  { name: "hairline", utility: "border-hairline", hexLight: "#eadfca", hexDark: "#1f4856" },
];

export const TEXT: PaletteEntry[] = [
  { name: "ink-body", utility: "text-ink-body", hexLight: "#29505b", hexDark: "#e2f4f7" },
  { name: "ink-display", utility: "text-ink-display", hexLight: "#0c3440", hexDark: "#f3fcfd" },
  { name: "ink-muted", utility: "text-ink-muted", hexLight: "#4f6f78", hexDark: "#9cc3cc" },
  { name: "on-accent", utility: "text-on-accent (on bg-accent)", hexLight: "#062a33", hexDark: "#062a33" },
];

export const SPLASH: PaletteEntry[] = [
  { name: "accent", utility: "bg-accent (pool aqua, with text-on-accent)", hexLight: "#19d3e3", hexDark: "#3de4f2" },
  { name: "accent-strong", utility: "bg-accent-strong / border-accent-strong (meters, rings)", hexLight: "#0897ad", hexDark: "#3de4f2" },
  { name: "accent-faded", utility: "bg-accent-faded", hexLight: "#dff7fa", hexDark: "#0e3c47" },
  { name: "accent-display", utility: "text-accent-display", hexLight: "#0a6678", hexDark: "#8cf1f8" },
  { name: "coral", utility: "bg-coral (complement of aqua)", hexLight: "#ff6b57", hexDark: "#ff8672" },
  { name: "coral-strong", utility: "bg-coral-strong", hexLight: "#d9442f", hexDark: "#ff8672" },
  { name: "coral-faded", utility: "bg-coral-faded", hexLight: "#ffe8e3", hexDark: "#44231e" },
  { name: "coral-display", utility: "text-coral-display", hexLight: "#a8321f", hexDark: "#ffbfb1" },
  { name: "signal", utility: "bg-signal (sunshine yellow, rewards)", hexLight: "#ffc933", hexDark: "#ffd24d" },
  { name: "signal-faded", utility: "bg-signal-faded", hexLight: "#fff3c4", hexDark: "#3d3414" },
  { name: "signal-display", utility: "text-signal-display", hexLight: "#7a5200", hexDark: "#ffe08a" },
  { name: "leaf", utility: "bg-leaf (living things)", hexLight: "#62c46a", hexDark: "#8fe08f" },
  { name: "leaf-strong", utility: "bg-leaf-strong", hexLight: "#3a9444", hexDark: "#8fe08f" },
  { name: "leaf-faded", utility: "bg-leaf-faded", hexLight: "#e4f5e3", hexDark: "#1b3a1f" },
  { name: "leaf-display", utility: "text-leaf-display", hexLight: "#25652d", hexDark: "#bff2bf" },
  { name: "peach", utility: "bg-peach (soft apricot)", hexLight: "#ffbf9b", hexDark: "#ffb98f" },
  { name: "peach-faded", utility: "bg-peach-faded", hexLight: "#ffeadb", hexDark: "#3d2a1f" },
  { name: "peach-display", utility: "text-peach-display (warm brown)", hexLight: "#8a4a2f", hexDark: "#ffd2b3" },
  { name: "lilac", utility: "bg-lilac (rare, special touches)", hexLight: "#b9a6f2", hexDark: "#b9a6f2" },
  { name: "forest", utility: "bg-forest / outlines (deep ocean)", hexLight: "#0c3440", hexDark: "#061a20" },
  { name: "danger", utility: "bg-danger / text-danger", hexLight: "oklch(64% 0.22 25)", hexDark: "oklch(72% 0.20 22)" },
  { name: "danger-faded", utility: "bg-danger-faded", hexLight: "oklch(96% 0.025 25)", hexDark: "oklch(22% 0.05 22)" },
  { name: "danger-display", utility: "bg-danger-display / text-danger-display", hexLight: "oklch(55% 0.20 25)", hexDark: "oklch(82% 0.18 22)" },
];

export const FONTS = {
  display: "Quicksand",
  body: "Nunito",
};
