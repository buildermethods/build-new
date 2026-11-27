import { Head, Link, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { Button } from "@/components/ui/button"

import type { PageProps } from "@/types/inertia"

const DESCRIPTION = "Your Nest Quest home: see how many quests are ready and jump to the Quest Board."

export default function Dashboard() {
  const { props } = usePage<PageProps<{ available_count: number }>>()
  const user = props.current_user
  const count = props.available_count ?? 0

  return (
    <>
      <Head title="Home">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Home" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <h1>Welcome{user?.email ? `, ${user.email}` : ""}</h1>
        <p className="mt-2">
          {count === 0
            ? "No quests are waiting. Add a task on the Quest Board to begin."
            : `${count} ${count === 1 ? "quest is" : "quests are"} ready for you.`}
        </p>
        <Button asChild className="mt-6">
          <Link href="/quests">Open the Quest Board</Link>
        </Button>
      </AppShell>
    </>
  )
}
