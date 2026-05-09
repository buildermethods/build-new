import * as React from "react"
import { Link, router, usePage } from "@inertiajs/react"
import {
  ChevronsLeft,
  ChevronsRight,
  Home,
  LogOut,
  Menu,
  Settings,
  Shield,
  User,
  X,
} from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { ThemeToggle } from "@/components/ui/theme-toggle"
import { cn } from "@/lib/utils"
import type { PageProps } from "@/types/inertia"

const STORAGE_KEY = "main-nav-open"
const BRAND = "Build New"

export type NavItemDef = {
  href: string
  icon: React.ComponentType<{ className?: string }>
  label: string
  match: (url: string) => boolean
}

const DEFAULT_NAV_ITEMS: NavItemDef[] = [
  {
    href: "/dashboard",
    icon: Home,
    label: "Home",
    match: (url) => url === "/" || url.startsWith("/dashboard"),
  },
]

function useMainNavOpen() {
  const [open, setOpen] = React.useState<boolean>(true)
  React.useEffect(() => {
    if (typeof window === "undefined") return
    const stored = window.localStorage.getItem(STORAGE_KEY)
    if (stored !== null) setOpen(stored === "true")
  }, [])
  React.useEffect(() => {
    if (typeof window === "undefined") return
    window.localStorage.setItem(STORAGE_KEY, String(open))
  }, [open])
  return [open, setOpen] as const
}

export function MainNav({
  items = DEFAULT_NAV_ITEMS,
  brandHref = "/dashboard",
}: {
  items?: NavItemDef[]
  brandHref?: string
} = {}) {
  const [open, setOpen] = useMainNavOpen()
  const [mobileOpen, setMobileOpen] = React.useState(false)

  return (
    <>
      <aside
        className={cn(
          "hidden shrink-0 flex-col border-r border-hairline bg-page transition-[width] duration-200 lg:flex",
          open ? "w-56" : "w-14",
        )}
      >
        <RailBody
          open={open}
          onToggle={() => setOpen(!open)}
          items={items}
          brandHref={brandHref}
        />
      </aside>

      {mobileOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <div
            className="absolute inset-0 bg-ink-display/40 backdrop-blur-sm"
            onClick={() => setMobileOpen(false)}
            aria-hidden
          />
          <aside className="absolute left-0 top-0 flex h-full w-64 flex-col bg-page shadow-xl">
            <div className="flex h-14 shrink-0 items-center justify-between border-b border-hairline px-4">
              <span className="font-display text-sm font-semibold text-ink-display">
                {BRAND}
              </span>
              <button
                type="button"
                onClick={() => setMobileOpen(false)}
                className="inline-flex h-8 w-8 cursor-pointer items-center justify-center rounded-md text-ink-muted hover:bg-surface hover:text-ink-display"
                aria-label="Close navigation"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <RailNav open items={items} onClose={() => setMobileOpen(false)} />
            <div className="border-t border-hairline p-2">
              <UserMenu open />
            </div>
          </aside>
        </div>
      )}

      <button
        type="button"
        onClick={() => setMobileOpen(true)}
        className="fixed right-3 top-3 z-30 inline-flex h-9 w-9 cursor-pointer items-center justify-center rounded-md border border-hairline bg-page text-ink-body hover:bg-surface lg:hidden"
        aria-label="Open navigation"
      >
        <Menu className="h-4 w-4" />
      </button>
    </>
  )
}

function RailBody({
  open,
  onToggle,
  items,
  brandHref,
}: {
  open: boolean
  onToggle: () => void
  items: NavItemDef[]
  brandHref: string
}) {
  return (
    <>
      <div
        className={cn(
          "flex h-14 shrink-0 items-center gap-3 border-b border-hairline px-3",
          open ? "justify-between" : "justify-center",
        )}
      >
        <Link
          href={brandHref}
          className="flex min-w-0 items-center gap-2 text-ink-display no-underline"
          aria-label={BRAND}
        >
          <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-md bg-accent-faded font-display text-sm font-semibold text-accent">
            {BRAND.charAt(0)}
          </span>
          {open && (
            <span className="truncate font-display text-sm font-semibold">
              {BRAND}
            </span>
          )}
        </Link>
        {open && (
          <button
            type="button"
            onClick={onToggle}
            className="inline-flex h-8 w-8 shrink-0 cursor-pointer items-center justify-center rounded-md text-ink-muted hover:bg-surface hover:text-ink-display"
            aria-label="Collapse sidebar"
          >
            <ChevronsLeft className="h-4 w-4" />
          </button>
        )}
      </div>

      <RailNav open={open} items={items} />

      <div className="border-t border-hairline p-2">
        <UserMenu open={open} />
      </div>

      {!open && (
        <div className="border-t border-hairline p-2">
          <button
            type="button"
            onClick={onToggle}
            className="flex h-9 w-full cursor-pointer items-center justify-center rounded-md text-ink-muted hover:bg-surface hover:text-ink-display"
            aria-label="Expand sidebar"
          >
            <ChevronsRight className="h-4 w-4" />
          </button>
        </div>
      )}
    </>
  )
}

function RailNav({
  open,
  items,
  onClose,
}: {
  open: boolean
  items: NavItemDef[]
  onClose?: () => void
}) {
  const { url } = usePage()
  return (
    <nav className="flex flex-1 flex-col gap-1 p-2 text-sm">
      {items.map((item) => (
        <NavItem
          key={item.href}
          href={item.href}
          icon={item.icon}
          label={item.label}
          active={item.match(url)}
          open={open}
          onClick={onClose}
        />
      ))}
    </nav>
  )
}

function NavItem({
  href,
  icon: Icon,
  label,
  active,
  open,
  onClick,
}: {
  href: string
  icon: React.ComponentType<{ className?: string }>
  label: string
  active?: boolean
  open: boolean
  onClick?: () => void
}) {
  return (
    <div className="group/nav-item relative">
      <Link
        href={href}
        onClick={onClick}
        aria-label={open ? undefined : label}
        className={cn(
          "flex items-center gap-3 rounded-md no-underline",
          open ? "px-3 py-2" : "mx-auto h-9 w-9 justify-center",
          active
            ? "bg-accent-faded text-accent"
            : "text-ink-body hover:bg-surface hover:text-ink-display",
        )}
      >
        <Icon className="h-4 w-4 shrink-0" />
        {open && <span className="truncate">{label}</span>}
      </Link>
      {!open && (
        <span
          role="tooltip"
          className="pointer-events-none absolute left-full top-1/2 z-50 ml-2 -translate-y-1/2 whitespace-nowrap rounded-md border border-hairline bg-page px-2 py-1 text-xs font-medium text-ink-display opacity-0 shadow-md transition-opacity group-hover/nav-item:opacity-100"
        >
          {label}
        </span>
      )}
    </div>
  )
}

function UserMenu({ open }: { open: boolean }) {
  const { props } = usePage<PageProps>()
  const email = props.current_user?.email ?? ""
  const isAdmin = props.current_user?.admin ?? false
  const initial = email.charAt(0).toUpperCase() || "?"

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          aria-label={open ? undefined : email || "Account"}
          className={cn(
            "group/user relative flex w-full cursor-pointer items-center gap-3 rounded-md text-left text-ink-body hover:bg-surface hover:text-ink-display focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent",
            open ? "px-2 py-2" : "h-10 justify-center",
          )}
        >
          <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-accent-faded text-xs font-semibold text-accent">
            {initial}
          </span>
          {open ? (
            <span className="min-w-0 flex-1 truncate text-sm">{email}</span>
          ) : (
            <span className="pointer-events-none absolute left-full top-1/2 z-50 ml-2 -translate-y-1/2 whitespace-nowrap rounded-md border border-hairline bg-page px-2 py-1 text-xs font-medium text-ink-display opacity-0 shadow-md transition-opacity group-hover/user:opacity-100">
              {email}
            </span>
          )}
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent side="top" align="start" className="w-56">
        <DropdownMenuLabel className="normal-case tracking-normal">
          <span className="block text-[10px] uppercase tracking-wider text-ink-muted">
            Signed in as
          </span>
          <span className="block truncate text-xs font-medium text-ink-display">
            {email}
          </span>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem asChild>
          <Link href="/profile" className="no-underline">
            <User /> Profile
          </Link>
        </DropdownMenuItem>
        <DropdownMenuItem asChild>
          <Link href="/settings" className="no-underline">
            <Settings /> Settings
          </Link>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <div className="px-2 py-2">
          <ThemeToggle block />
        </div>
        <DropdownMenuSeparator />
        {isAdmin && (
          <DropdownMenuItem asChild>
            <Link href="/admin/users" className="no-underline">
              <Shield /> Admin
            </Link>
          </DropdownMenuItem>
        )}
        <DropdownMenuItem
          onSelect={(event) => {
            event.preventDefault()
            router.delete("/logout")
          }}
        >
          <LogOut /> Sign out
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
