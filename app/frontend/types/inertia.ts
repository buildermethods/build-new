import type { PageProps as InertiaPageProps } from "@inertiajs/core"

export type CurrentUser = {
  id: number
  email: string
  timezone: string | null
  admin: boolean
} | null

export type Todo = {
  id: number
  description: string
  completed: boolean
  created_at: string
}

export type SharedProps = {
  current_user: CurrentUser
  flash: {
    notice: string | null
    alert: string | null
  }
  errors: Record<string, string>
}

export type PageProps<T extends Record<string, unknown> = Record<string, unknown>> =
  SharedProps & T & InertiaPageProps
