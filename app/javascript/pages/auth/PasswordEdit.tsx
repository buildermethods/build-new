import { FormEvent } from "react"
import { Head, useForm, usePage } from "@inertiajs/react"
import { AuthShell } from "@/components/AuthShell"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

import type { PageProps } from "@/types/inertia"

type Props = { token: string }

export default function PasswordEdit({ token }: Props) {
  const { props } = usePage<PageProps<Props>>()
  const form = useForm({ password: "" })

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.patch(`/passwords/${token}`)
  }

  const errors = props.errors ?? {}

  return (
    <>
      <Head title="Choose a new password">
        <meta name="description" content="Set a new password for your account." />
        <meta property="og:title" content="Choose a new password" />
        <meta property="og:description" content="Set a new password for your account." />
      </Head>
      <AuthShell>
        <h1>Choose a new password</h1>
        <form onSubmit={submit} className="mt-6 space-y-4">
          <div className="space-y-2">
            <label
              htmlFor="password"
              className="block text-sm font-medium text-ink-display"
            >
              New password
            </label>
            <Input
              id="password"
              type="password"
              autoComplete="new-password"
              required
              aria-invalid={!!errors.password}
              value={form.data.password}
              onChange={(e) => form.setData("password", e.target.value)}
            />
            {errors.password && (
              <p className="text-xs text-signal">{errors.password}</p>
            )}
          </div>
          <Button type="submit" disabled={form.processing}>
            Update password
          </Button>
        </form>
      </AuthShell>
    </>
  )
}
