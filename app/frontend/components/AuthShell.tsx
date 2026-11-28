import * as React from "react"
import { Link } from "@inertiajs/react"
import { Logo } from "@/components/Logo"

export function AuthShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-8 bg-page px-4 py-12 text-ink-body">
      <Link href="/" aria-label="Nest Quest home" className="no-underline">
        <Logo size="lg" stacked tagline />
      </Link>
      <div className="callout w-full max-w-md">{children}</div>
    </div>
  )
}
