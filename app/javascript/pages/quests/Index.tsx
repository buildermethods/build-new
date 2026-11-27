import { Head } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"

const DESCRIPTION = "Browse your household tasks as fantasy quests on the Nest Quest Quest Board, with time, difficulty and rewards for each."

export default function QuestsIndex() {
  return (
    <>
      <Head title="Quest Board">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Quest Board" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Quest Board" description="Your chores, as quests." />
        <p className="mt-8">Coming soon.</p>
      </AppShell>
    </>
  )
}
