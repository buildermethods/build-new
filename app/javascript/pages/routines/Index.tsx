import { Head } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"

const DESCRIPTION = "Build repeatable Nest Quest routines from ordered steps, like the school morning launch or the Sunday reset, and track today's progress."

export default function RoutinesIndex() {
  return (
    <>
      <Head title="Routines">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Routines" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Routines" description="Repeatable sequences of steps." />
        <p className="mt-8">Coming soon.</p>
      </AppShell>
    </>
  )
}
