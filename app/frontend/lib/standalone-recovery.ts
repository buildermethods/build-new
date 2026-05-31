// Standalone (iOS Home Screen PWA) recovery guard.
//
// Browser-only. Install this from the CLIENT Inertia entrypoint only — never
// from the SSR entrypoint, since it touches `window`/`document`.
//
// Why this exists: when an app is saved to the iPhone Home Screen and run in
// standalone mode, it runs under a tighter WebKit memory ceiling and has no
// browser chrome to silently reload from. When iOS discards or long-suspends
// the backgrounded WebKit process, the app can return to a dead JS context —
// frozen, unscrollable, untappable. Regular Safari tabs hide this by
// transparently reloading; standalone apps don't. This guard reloads the page
// when it's likely returning to a dead context: (a) a bfcache restore, and
// (b) a resume after being hidden longer than RESUME_RELOAD_AFTER_MS.
//
// The reload is intentionally suppressed while unsaved edits exist (see the
// ref-counted block registry below) — never destroy unsaved work.

const RESUME_RELOAD_AFTER_MS = 30 * 60 * 1000 // 30 minutes

// Reference-counted opt-out. Each active edit surface holds one reference;
// the guard reloads only when the count is zero. Ref-counting (not a single
// boolean) lets multiple dirty editors compose, and ensures an unmount can't
// strand the block held by a sibling.
let blockCount = 0

/**
 * Register an unsaved-work block. Returns a release function; call it once the
 * work is saved (or the surface unmounts). Calling release more than once is a
 * no-op. Prefer the `useBlockAutoReload` React hook over calling this directly.
 */
export function blockAutoReload(): () => void {
  blockCount += 1
  let released = false
  return () => {
    if (released) return
    released = true
    blockCount = Math.max(0, blockCount - 1)
  }
}

function isStandalone(): boolean {
  if (typeof window === "undefined") return false
  const matches =
    typeof window.matchMedia === "function" &&
    window.matchMedia("(display-mode: standalone)").matches
  const iosStandalone =
    (window.navigator as Navigator & { standalone?: boolean }).standalone === true
  return matches || iosStandalone
}

function reloadBlocked(): boolean {
  if (blockCount > 0) return true
  // Escape hatch for non-React surfaces that hold unsaved state.
  return (
    (window as unknown as { __blockAutoReload?: boolean }).__blockAutoReload === true
  )
}

let installed = false

/**
 * Install the standalone recovery listeners. No-op unless running standalone,
 * and safe to call more than once (idempotent). Browser-only.
 */
export function installStandaloneRecovery(): void {
  if (installed || typeof window === "undefined") return
  if (!isStandalone()) return
  installed = true

  // (a) bfcache restore: a page restored from the back/forward cache may be
  // running a stale/dead JS context. Reload to get a fresh one.
  window.addEventListener("pageshow", (event) => {
    if ((event as PageTransitionEvent).persisted && !reloadBlocked()) {
      window.location.reload()
    }
  })

  // (b) resume after a long background suspension: track when we went hidden
  // and reload if we come back visible after more than the threshold.
  let hiddenAt: number | null = null
  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
      hiddenAt = Date.now()
    } else if (document.visibilityState === "visible") {
      if (
        hiddenAt !== null &&
        Date.now() - hiddenAt > RESUME_RELOAD_AFTER_MS &&
        !reloadBlocked()
      ) {
        window.location.reload()
      }
      hiddenAt = null
    }
  })
}
