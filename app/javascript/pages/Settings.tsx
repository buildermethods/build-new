import { Head } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"

export default function Settings() {
  return (
    <>
      <Head title="Settings">
        <meta name="description" content="Manage your account settings." />
        <meta property="og:title" content="Settings" />
        <meta property="og:description" content="Manage your account settings." />
      </Head>
      <AppShell>
        <h1>Settings</h1>
        <p className="mt-2">Application settings will go here.</p>
      </AppShell>
    </>
  )
}
