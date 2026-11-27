import type { PageProps as InertiaPageProps } from "@inertiajs/core"

export type CurrentUser = {
  id: number
  email: string
  timezone: string | null
  admin: boolean
} | null

export type Quest = {
  id: number
  title: string
  notes: string | null
  room: string
  category: string
  duration_minutes: number
  effort: "tiny" | "small" | "medium" | "large" | "boss"
  difficulty: "Easy" | "Medium" | "Hard" | "Boss"
  priority: "low" | "normal" | "high"
  due_on: string | null
  next_due_on: string | null
  deferred_until: string | null
  recurrence_kind: "none" | "calendar" | "completion"
  recurrence_interval_days: number | null
  recurrence_weekdays: number[]
  status: "active" | "paused" | "archived"
  available: boolean
  fantasy_title: string
  monster: { key: string; name: string }
  xp: number
  coins: number
}

export type QuestHistoryItem = {
  id: number
  task_id: number
  title: string
  completed_at: string
  xp: number
  coins: number
}

export type QuestOptions = {
  rooms: string[]
  categories: string[]
  efforts: string[]
  priorities: string[]
  recurrence_kinds: string[]
}

export type Player = {
  level: number
  xp: number
  coins: number
  xp_into_level: number
  xp_for_next_level: number
}

export type Victory = {
  id: number
  monster: string
  quest_title: string
  task_title: string
  xp: number
  coins: number
  level: number
  leveled_up: boolean
}

export type SharedProps = {
  current_user: CurrentUser
  player: Player | null
  flash: {
    notice: string | null
    alert: string | null
    victory: Victory | null
  }
  errors: Record<string, string>
}

export type PageProps<T extends Record<string, unknown> = Record<string, unknown>> =
  SharedProps & T & InertiaPageProps
