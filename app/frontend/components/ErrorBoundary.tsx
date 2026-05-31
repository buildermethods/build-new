import * as React from "react"
import { Button } from "@/components/ui/button"

interface ErrorBoundaryProps {
  children: React.ReactNode
}

interface ErrorBoundaryState {
  hasError: boolean
}

/**
 * Top-level error boundary wrapping the Inertia <App>. Without it, an uncaught
 * render error leaves a dead, unscrollable shell — indistinguishable from a
 * frozen tab, with no browser chrome to reload from in a standalone PWA. The
 * "Reload" button gives the user a guaranteed way out.
 */
export class ErrorBoundary extends React.Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  constructor(props: ErrorBoundaryProps) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true }
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error("Uncaught render error:", error, info)
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex min-h-screen flex-col items-center justify-center gap-4 bg-page px-6 text-center">
          <h1>Something went wrong</h1>
          <p>The app hit an unexpected error. Reloading usually fixes it.</p>
          <Button onClick={() => window.location.reload()}>Reload</Button>
        </div>
      )
    }

    return this.props.children
  }
}
