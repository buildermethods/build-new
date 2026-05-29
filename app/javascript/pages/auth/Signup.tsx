import { FormEvent, useEffect } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"
import { AuthShell } from "@/components/AuthShell"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

import type { PageProps } from "@/types/inertia"

export default function Signup() {
  const { props } = usePage<PageProps>()
  const form = useForm({ email: "", password: "", timezone: "" })

  useEffect(() => {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone
    if (tz) form.setData("timezone", tz)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.post("/signup")
  }

  const errors = props.errors ?? {}

  return (
    <>
      <Head title="Sign up">
        <meta name="description" content="Create a new account to get started." />
        <meta property="og:title" content="Sign up" />
        <meta property="og:description" content="Create a new account to get started." />
      </Head>
      <AuthShell>
        <div className="text-center">
          <h2>Create your account</h2>
          <p className="mt-2 text-sm text-ink-muted">
            Already have an account? <Link href="/login">Log in</Link>
          </p>
        </div>

        <form onSubmit={submit} className="mt-6 space-y-4">
          <div className="space-y-2">
            <label htmlFor="email">Email</label>
            <Input
              id="email"
              type="email"
              autoComplete="email"
              autoFocus
              required
              aria-invalid={!!errors.email}
              value={form.data.email}
              onChange={(e) => form.setData("email", e.target.value)}
            />
            {errors.email && (
              <p className="text-xs text-danger-display">{errors.email}</p>
            )}
          </div>
          <div className="space-y-2">
            <label htmlFor="password">Password</label>
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
              <p className="text-xs text-danger-display">{errors.password}</p>
            )}
          </div>
          <Button type="submit" disabled={form.processing}>
            Create account
          </Button>
        </form>
      </AuthShell>
    </>
  )
}
