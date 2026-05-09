import * as React from "react"

export function AuthShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-page px-4 py-12 text-ink-body">
      <div className="callout w-full max-w-md">{children}</div>
    </div>
  )
}
