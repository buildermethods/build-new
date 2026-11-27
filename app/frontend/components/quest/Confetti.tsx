const COLORS = ["bg-signal", "bg-lilac", "bg-peach", "bg-accent"]

// A short burst of sparkles for big moments. Fixed positions (no randomness, so
// server and client render the same markup); CSS-only and disabled for people
// who prefer reduced motion or switch it off in Settings.
export function Confetti() {
  return (
    <div className="confetti" aria-hidden="true">
      {Array.from({ length: 16 }, (_, i) => (
        <span
          key={i}
          className={COLORS[i % COLORS.length]}
          style={{ left: `${(i * 37) % 100}%`, animationDelay: `${(i % 6) * 90}ms` }}
        />
      ))}
    </div>
  )
}
