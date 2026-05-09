import { Head, Link } from "@inertiajs/react"
import { AdminShell } from "@/components/AdminShell"
import { Badge } from "@/components/ui/badge"

type UserDetail = {
  id: number
  email: string
  admin: boolean
  timezone: string | null
  created_at: string
  updated_at: string
}

export default function AdminUserShow({ user }: { user: UserDetail }) {
  return (
    <>
      <Head title={user.email}>
        <meta name="description" content={`User detail for ${user.email}.`} />
        <meta property="og:title" content={user.email} />
        <meta property="og:description" content={`User detail for ${user.email}.`} />
      </Head>
      <AdminShell>
        <div className="border-b border-hairline pb-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <h1>{user.email}</h1>
              <p className="mt-1">User #{user.id}</p>
            </div>
            <div className="flex items-center gap-2">
              {user.admin && <Badge tone="accent">Admin</Badge>}
              <Link
                href="/admin/users"
                className="text-sm text-ink-muted no-underline hover:text-ink-display"
              >
                Back to users
              </Link>
            </div>
          </div>
        </div>

        <dl className="mt-6 grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-[max-content_1fr]">
          <DetailRow label="Email" value={user.email} />
          <DetailRow label="Admin" value={user.admin ? "Yes" : "No"} />
          <DetailRow label="Timezone" value={user.timezone ?? "—"} />
          <DetailRow label="Created" value={formatDateTime(user.created_at)} />
          <DetailRow label="Updated" value={formatDateTime(user.updated_at)} />
        </dl>
      </AdminShell>
    </>
  )
}

function DetailRow({ label, value }: { label: string; value: string }) {
  return (
    <>
      <dt className="text-sm text-ink-muted">{label}</dt>
      <dd className="text-sm text-ink-body">{value}</dd>
    </>
  )
}

function formatDateTime(iso: string) {
  return new Date(iso).toLocaleString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  })
}
