import { ReactNode, useState } from "react"
import { Link, router, usePage } from "@inertiajs/react"
import { ChevronDown, LogOut, Menu, Settings, User, X } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { cn } from "@/lib/utils"
import type { PageProps } from "@/types/inertia"

type NavItem = { label: string; href: string }

const NAV: NavItem[] = [
  { label: "Home", href: "/dashboard" },
  { label: "Page A", href: "#" },
  { label: "Page B", href: "#" },
  { label: "Page C", href: "#" },
]

export function AppShell({
  title,
  children,
}: {
  title: string
  children: ReactNode
}) {
  const { props, url } = usePage<PageProps>()
  const [mobileOpen, setMobileOpen] = useState(false)
  const user = props.current_user

  return (
    <div className="flex min-h-svh bg-background text-foreground">
      <Sidebar
        url={url}
        mobileOpen={mobileOpen}
        onClose={() => setMobileOpen(false)}
      />

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex h-14 items-center gap-2 bg-background/80 px-4 backdrop-blur md:px-6">
          <Button
            size="icon"
            variant="ghost"
            className="md:hidden"
            onClick={() => setMobileOpen(true)}
            aria-label="Open navigation"
          >
            <Menu className="size-5" />
          </Button>

          <h1 className="text-sm font-medium text-muted-foreground">{title}</h1>

          <div className="ml-auto">
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="sm" className="gap-2">
                  <span className="hidden max-w-[180px] truncate sm:inline">
                    {user?.email}
                  </span>
                  <ChevronDown className="size-4 opacity-60" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-52">
                {user?.email && (
                  <>
                    <DropdownMenuLabel className="truncate text-xs font-normal text-muted-foreground">
                      {user.email}
                    </DropdownMenuLabel>
                    <DropdownMenuSeparator />
                  </>
                )}
                <DropdownMenuItem asChild>
                  <Link href="/settings">
                    <Settings /> Settings
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href="/profile">
                    <User /> Profile
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  variant="destructive"
                  onSelect={() => router.delete("/logout")}
                >
                  <LogOut /> Log out
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </header>

        <main className="flex-1 p-6 md:p-10">{children}</main>
      </div>
    </div>
  )
}

function Sidebar({
  url,
  mobileOpen,
  onClose,
}: {
  url: string
  mobileOpen: boolean
  onClose: () => void
}) {
  return (
    <>
      {mobileOpen && (
        <div
          className="fixed inset-0 z-40 bg-foreground/30 md:hidden"
          onClick={onClose}
          aria-hidden
        />
      )}
      <aside
        className={cn(
          "fixed inset-y-0 left-0 z-50 flex w-64 flex-col border-r border-sidebar-border bg-sidebar text-sidebar-foreground transition-transform md:static md:translate-x-0",
          mobileOpen ? "translate-x-0" : "-translate-x-full"
        )}
      >
        <div className="flex h-14 items-center justify-between gap-2 border-b border-sidebar-border px-4">
          <Link
            href="/dashboard"
            className="text-sm font-semibold tracking-tight"
            onClick={onClose}
          >
            Build New
          </Link>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1 text-sidebar-foreground/70 hover:text-sidebar-foreground md:hidden"
            aria-label="Close navigation"
          >
            <X className="size-5" />
          </button>
        </div>

        <nav className="flex flex-1 flex-col gap-1 p-3">
          {NAV.map((item) => {
            const active = isActive(url, item.href)
            return (
              <Link
                key={item.label}
                href={item.href}
                onClick={onClose}
                className={cn(
                  "rounded-md px-3 py-2 text-sm font-medium transition-colors",
                  active
                    ? "bg-sidebar-accent text-sidebar-accent-foreground"
                    : "text-sidebar-foreground/80 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
                )}
              >
                {item.label}
              </Link>
            )
          })}
        </nav>
      </aside>
    </>
  )
}

function isActive(url: string, href: string) {
  if (href === "#") return false
  const path = url.split("?")[0]
  return path === href || path.startsWith(`${href}/`)
}
