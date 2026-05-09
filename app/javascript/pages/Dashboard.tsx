import { Head, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"

import type { PageProps } from "@/types/inertia"

export default function Dashboard() {
  const { props } = usePage<PageProps>()
  const user = props.current_user

  return (
    <>
      <Head title="Home">
        <meta name="description" content="Your account home." />
        <meta property="og:title" content="Home" />
        <meta property="og:description" content="Your account home." />
      </Head>
      <AppShell>
        <h1>Home</h1>
        <p className="mt-2">
          Welcome to your account{user?.email ? `, ${user.email}` : ""}.
        </p>
      </AppShell>
    </>
  )
}
