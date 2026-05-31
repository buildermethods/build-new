import { useEffect } from "react"
import { blockAutoReload } from "@/lib/standalone-recovery"

/**
 * Hold a standalone-recovery auto-reload block while `active` is true, releasing
 * it on cleanup. Wire this into any surface with unsaved edits (rich-text /
 * markdown editors, autosave/debounced forms, anything with `useForm`/`isDirty`):
 * pass `active = true` from the first edit until the save lands. While any such
 * block is held, the iOS standalone recovery guard will not reload the page, so
 * unsaved work is never destroyed.
 *
 * Ref-counted under the hood, so multiple dirty surfaces compose correctly.
 */
export function useBlockAutoReload(active: boolean): void {
  useEffect(() => {
    if (!active) return
    return blockAutoReload()
  }, [active])
}
