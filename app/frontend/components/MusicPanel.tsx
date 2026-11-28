import * as React from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

export type Playlist = { key: string; label: string; blurb: string; spotify_id: string }

const STORAGE_KEY = "nestquest:music"
const SPOTIFY_LINK = /open\.spotify\.com\/(?:intl-[a-z]+\/)?(playlist|album|track|episode|show)\/([A-Za-z0-9]+)/

// Pulls the kind and id out of a pasted Spotify link, or null.
export function parseSpotifyLink(text: string): { kind: string; id: string } | null {
  const match = SPOTIFY_LINK.exec(text.trim())
  return match ? { kind: match[1], id: match[2] } : null
}

type Choice = { kind: string; id: string }

// An optional "play something while you tidy" panel. Nothing is loaded from
// Spotify until the player asks for it, so no data leaves the page by default.
// The choice is remembered in this browser only.
export function MusicPanel({ playlists }: { playlists: Playlist[] }) {
  const [open, setOpen] = React.useState(false)
  const [choice, setChoice] = React.useState<Choice>({ kind: "playlist", id: playlists[0]?.spotify_id ?? "" })
  const [link, setLink] = React.useState("")
  const [error, setError] = React.useState("")

  React.useEffect(() => {
    try {
      const saved = JSON.parse(window.localStorage.getItem(STORAGE_KEY) ?? "null")
      if (saved?.id && /^[A-Za-z0-9]+$/.test(saved.id)) setChoice(saved)
    } catch {
      // storage can be unavailable; the default playlist is fine
    }
  }, [])

  const pick = (next: Choice) => {
    setChoice(next)
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next))
    } catch {
      // not remembering is fine
    }
  }

  const useLink = () => {
    const parsed = parseSpotifyLink(link)
    if (!parsed) return setError("That doesn't look like a Spotify link. Copy one from Spotify's Share menu.")
    setError("")
    pick(parsed)
    setLink("")
  }

  return (
    <section className="rounded-xl border border-hairline bg-surface p-4" aria-label="Music">
      <h2 className="heading-sm">Add some music?</h2>
      <p className="caption mt-1">A little music keeps the energy up. Optional, and nothing loads from Spotify until you ask.</p>

      {!open ? (
        <Button className="mt-3" variant="secondary" onClick={() => setOpen(true)}>Show the Spotify player</Button>
      ) : (
        <div className="mt-3 space-y-3">
          <div className="flex flex-wrap gap-2" role="group" aria-label="Playlists">
            {playlists.map((p) => (
              <button
                key={p.key}
                type="button"
                className="toggle-button"
                aria-pressed={choice.kind === "playlist" && choice.id === p.spotify_id}
                title={p.blurb}
                onClick={() => pick({ kind: "playlist", id: p.spotify_id })}
              >
                {p.label}
              </button>
            ))}
          </div>
          <iframe
            key={`${choice.kind}-${choice.id}`}
            title="Spotify player"
            src={`https://open.spotify.com/embed/${choice.kind}/${choice.id}?utm_source=generator`}
            width="100%"
            height="152"
            style={{ border: 0, borderRadius: 12 }}
            allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"
            loading="lazy"
          />
          <div className="flex flex-wrap items-center gap-2">
            <Input
              aria-label="Paste a Spotify link"
              placeholder="Or paste your own Spotify link"
              value={link}
              onChange={(e) => setLink(e.target.value)}
              className="max-w-sm"
            />
            <Button size="sm" variant="secondary" onClick={useLink}>Use this</Button>
          </div>
          {error && <p className="text-sm text-danger-display" role="alert">{error}</p>}
          <p className="caption">Full songs need you to be signed in to Spotify in this browser; otherwise you'll hear previews.</p>
        </div>
      )}
    </section>
  )
}
