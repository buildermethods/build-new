import { Head } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"

const DESCRIPTION = "Visit your cosy Nest Quest cottage, spend the coins you earn on decorations and see your home grow brighter with every chore you finish."

export default function SanctuaryShow() {
  return (
    <>
      <Head title="Sanctuary">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="Sanctuary" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="Sanctuary" description="Your cosy cottage." />
        <p className="mt-8">Coming soon.</p>
      </AppShell>
    </>
  )
}
