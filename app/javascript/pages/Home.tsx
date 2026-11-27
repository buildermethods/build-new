import { Link, Head } from "@inertiajs/react"
import { Cottage } from "@/components/sanctuary/Cottage"
import { Button } from "@/components/ui/button"
import { MonsterArt } from "@/components/ui/monster-art"
import { RoomIcon } from "@/components/ui/room-icon"

const DESCRIPTION =
  "Nest Quest turns everyday chores into cosy fantasy quests. Defeat chaos monsters, earn XP and coins, and restore your cottage, with no guilt."

const STEPS = [
  {
    monster: "counter_goblins",
    title: "Your chores become quests",
    text: "Tell Nest Quest about your home and it suggests the usual housework with sensible frequencies. Every quest shows the real task in plain words.",
  },
  {
    monster: "laundry_troll",
    title: "Small wins add up",
    text: "Finish a chore, send a monster to sleep, earn XP and coins. Start with just two minutes; starting counts.",
  },
  {
    monster: "wardrobe_wraith",
    title: "Your cottage grows",
    text: "Spend your coins on decorations and unlock new rooms. Nothing you earn is ever taken away.",
  },
]

export default function Home() {
  return (
    <>
      <Head title="Nest Quest: defeat chaos, build calm">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Nest Quest: defeat chaos, build calm" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <main className="mx-auto max-w-5xl px-6 py-8">
        <header className="flex items-center justify-between gap-4">
          <p className="font-display text-lg font-semibold text-ink-display">Nest Quest</p>
          <Button asChild variant="ghost" size="sm">
            <Link href="/login">Log in</Link>
          </Button>
        </header>

        <section className="mt-10 grid items-center gap-10 md:grid-cols-2" aria-label="Welcome">
          <div>
            <h1>Defeat chaos. Build calm.</h1>
            <p className="mt-4 text-lg">
              Turn the work of running a home into a cosy adventure. Real chores, friendly monsters, and a cottage
              that grows as you do.
            </p>
            <div className="mt-6 flex flex-wrap items-center gap-3">
              <Button asChild size="lg">
                <Link href="/signup">Start your adventure</Link>
              </Button>
              <Button asChild size="lg" variant="secondary">
                <Link href="/login">Log in</Link>
              </Button>
            </div>
            <p className="mt-4 caption">No streaks to lose, no guilt. Skip or postpone anything, any time.</p>
          </div>
          <div className="relative">
            <Cottage
              placements={{ rug: "woven_rug", plant: "fern_pot", lamp: "table_lamp", wall: "meadow_frame" }}
              names={{ woven_rug: "Woven Rug", fern_pot: "Fern in a Pot", table_lamp: "Cosy Table Lamp", meadow_frame: "Framed Meadow" }}
            />
            <MonsterArt monster="counter_goblins" mood="sleepy" className="absolute -bottom-4 -left-3 h-20 w-20" />
            <MonsterArt monster="dust_bunny_horde" className="absolute -right-3 -top-6 h-20 w-20" />
          </div>
        </section>

        <section className="mt-16" aria-label="How it works">
          <h2>How it works</h2>
          <ol className="mt-6 grid list-none gap-4 p-0 md:grid-cols-3">
            {STEPS.map((step, i) => (
              <li key={step.title} className="rounded-2xl border border-hairline bg-surface p-5">
                <MonsterArt monster={step.monster} className="h-20 w-20" />
                <p className="mt-3 caption">Step {i + 1}</p>
                <h3 className="mt-1">{step.title}</h3>
                <p className="mt-2">{step.text}</p>
              </li>
            ))}
          </ol>
        </section>

        <section className="mt-16 rounded-2xl border border-hairline bg-surface p-6" aria-label="Every room">
          <h2>Made for every room of your home</h2>
          <ul className="mt-4 flex list-none flex-wrap gap-5 p-0">
            {[
              ["kitchen", "Kitchen"], ["bathroom", "Bathroom"], ["bedroom", "Bedrooms"], ["living_room", "Living room"],
              ["hallway", "Hallway"], ["utility", "Laundry"], ["garden", "Garden"],
            ].map(([room, label]) => (
              <li key={room} className="flex items-center gap-2">
                <RoomIcon room={room} className="h-10 w-10" />
                <span>{label}</span>
              </li>
            ))}
          </ul>
        </section>

        <footer className="mt-16 pb-6 text-center text-sm text-ink-muted">
          <p>Progress without punishment.</p>
        </footer>
      </main>
    </>
  )
}
