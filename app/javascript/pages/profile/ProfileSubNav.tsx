import { Link } from "@inertiajs/react"
import { cn } from "@/lib/utils"

const TABS = [
  { href: "/profile", label: "My details" },
  { href: "/profile/password", label: "Password" },
] as const

export function ProfileSubNav({ active }: { active: "details" | "password" }) {
  const activeHref = active === "details" ? "/profile" : "/profile/password"

  return (
    <nav className="flex items-end gap-6 border-b border-hairline">
      {TABS.map((tab) => {
        const isActive = tab.href === activeHref
        return (
          <Link
            key={tab.href}
            href={tab.href}
            className={cn(
              "-mb-px border-b-2 px-1 py-3 text-sm no-underline",
              isActive
                ? "border-accent font-medium text-accent"
                : "border-transparent text-ink-body hover:text-ink-display",
            )}
          >
            {tab.label}
          </Link>
        )
      })}
    </nav>
  )
}
