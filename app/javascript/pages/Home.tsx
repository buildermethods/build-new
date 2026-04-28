import { Link, Head } from "@inertiajs/react"

import { Button } from "@/components/ui/button"

export default function Home() {
  return (
    <>
      <Head title="Hello world">
        <meta
          name="description"
          content="Starter landing page for the Build New Rails + Inertia template — replace this copy with the real product pitch."
        />
      </Head>
      <main className="flex min-h-svh items-center justify-center px-6">
        <div className="flex flex-col items-center gap-8 text-center">
          <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">
            Hello world.
          </h1>
          <div className="flex flex-col items-center gap-3 sm:flex-row">
            <Button asChild size="lg">
              <Link href="/login">Log in</Link>
            </Button>
            <Button asChild size="lg" variant="outline">
              <Link href="/signup">Sign up</Link>
            </Button>
          </div>
        </div>
      </main>
    </>
  )
}
