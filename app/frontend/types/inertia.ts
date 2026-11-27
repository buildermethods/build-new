import type { PageProps as InertiaPageProps } from "@inertiajs/core"

export type CurrentUser = {
  id: number
  email: string
  timezone: string | null
  display_name: string | null
  reduced_motion: boolean
  admin: boolean
} | null

export type Quest = {
  id: number
  title: string
  notes: string | null
  room: string
  room_label: string | null
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

export type PlanQuest = {
  task_id: number
  quest_title: string
  real_task: string
  steps: string[]
  estimated_minutes: number
  difficulty: string
  monster: string
  monster_key: string
  xp: number
  coins: number
}

export type QuestPlan = {
  title: string
  intro: string
  encouragement: string
  source: "ai" | "rules"
  total_minutes: number
  buffer_minutes: number
  minutes: number
  energy: string
  quests: PlanQuest[]
}

export type EnergyMode = { key: string; label: string; description: string }

export type FocusTarget = {
  task_id: number
  monster_key?: string
  title: string
  quest_title: string
  minutes: number
  steps: string[]
}

export type Decoration = {
  key: string
  name: string
  slot: "rug" | "plant" | "lamp" | "wall"
  price: number
  owned: boolean
  equipped: boolean
}

export type SanctuaryData = {
  slots: string[]
  placements: Record<string, string>
  items: Decoration[]
  teaser: { key: string; name: string; price: number; coins_needed: number } | null
}

export type RoutineStep = { id: number; title: string; task_id: number | null; done_today: boolean }

export type Routine = {
  id: number
  name: string
  weekdays: number[]
  scheduled_today: boolean
  steps: RoutineStep[]
  done_count: number
  total: number
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

export type Badge = { key: string; name: string; description: string }

export type Victory = {
  id: number
  monster: string
  monster_key: string | null
  message: string
  badges: Badge[]
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
