import * as React from "react"
import { Home, Users } from "lucide-react"
import { MainNav, type NavItemDef } from "@/components/MainNav"

const ADMIN_NAV_ITEMS: NavItemDef[] = [
  {
    href: "/",
    icon: Home,
    label: "App Home",
    match: () => false,
  },
  {
    href: "/admin/users",
    icon: Users,
    label: "Users",
    match: (url) => url.startsWith("/admin/users"),
  },
]

export function AdminShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-page text-ink-body">
      <MainNav items={ADMIN_NAV_ITEMS} brandHref="/admin/users" />
      <main className="min-w-0 flex-1 px-6 py-8 sm:px-10">
        <div className="mx-auto max-w-4xl">{children}</div>
      </main>
    </div>
  )
}
