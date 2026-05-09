import * as React from "react"
import { MainNav } from "@/components/MainNav"

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-page text-ink-body">
      <MainNav />
      <main className="min-w-0 flex-1 px-6 py-8 sm:px-10">
        <div className="mx-auto max-w-4xl">{children}</div>
      </main>
    </div>
  )
}
