import { Link, Head } from "@inertiajs/react"
import { Button } from "@/components/ui/button"

const DESCRIPTION =
  "Nest Quest turns everyday chores into cosy fantasy quests. Defeat chaos monsters, earn XP and coins, and restore your cottage, with no guilt."

export default function Home() {
  return (
    <>
      <Head title="Nest Quest: defeat chaos, build calm">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Nest Quest: defeat chaos, build calm" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <main className="mx-auto flex min-h-screen max-w-2xl flex-col items-center justify-center px-4 py-16 text-center">
        <h1>Nest Quest</h1>
        <p className="mt-2 max-w-md text-ink-muted">
          Defeat chaos. Build calm. Turn the work of running a home into a cosy adventure.
        </p>
        <div className="mt-6 flex items-center gap-3">
          <Button asChild>
            <Link href="/signup">Sign up</Link>
          </Button>
          <Button asChild variant="secondary">
            <Link href="/login">Log in</Link>
          </Button>
        </div>
      </main>
    </>
  )
}
