import { Head, Link } from "@inertiajs/react"
import { ChevronRight, User as UserIcon } from "lucide-react"
import { AdminShell } from "@/components/AdminShell"
import { Badge } from "@/components/ui/badge"

type UserRow = {
  id: number
  email: string
  admin: boolean
  created_at: string
}

export default function AdminUsersIndex({ users }: { users: UserRow[] }) {
  return (
    <>
      <Head title="Users">
        <meta name="description" content="Manage users in the admin area." />
        <meta property="og:title" content="Users" />
        <meta property="og:description" content="Manage users in the admin area." />
      </Head>
      <AdminShell>
        <div className="border-b border-hairline pb-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <h1>Users</h1>
              <p className="mt-1">
                {users.length} {users.length === 1 ? "user" : "users"} in this app.
              </p>
            </div>
          </div>
        </div>

        <ul className="mt-6 divide-y divide-hairline overflow-hidden rounded-md border border-hairline bg-page">
          {users.map((user) => (
            <li key={user.id}>
              <Link
                href={`/admin/users/${user.id}`}
                className="flex items-center gap-3 px-4 py-3 no-underline hover:bg-surface"
              >
                <UserIcon className="h-4 w-4 text-ink-muted" />
                <div className="min-w-0 flex-1">
                  <div className="truncate text-sm font-medium text-ink-display">
                    {user.email}
                  </div>
                  <div className="truncate text-xs text-ink-muted">
                    Joined {formatDate(user.created_at)}
                  </div>
                </div>
                {user.admin && <Badge tone="accent">Admin</Badge>}
                <ChevronRight className="h-4 w-4 text-ink-muted" />
              </Link>
            </li>
          ))}
        </ul>
      </AdminShell>
    </>
  )
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  })
}
