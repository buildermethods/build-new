import { FormEvent } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"
import { AuthShell } from "@/components/AuthShell"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

import type { PageProps } from "@/types/inertia"

export default function Login() {
  const { props } = usePage<PageProps>()
  const form = useForm({ email: "", password: "" })

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.post("/login")
  }

  const baseError = props.errors?.base

  return (
    <>
      <Head title="Log in">
        <meta name="description" content="Log in to your account." />
        <meta property="og:title" content="Log in" />
        <meta property="og:description" content="Log in to your account." />
      </Head>
      <AuthShell>
        <div className="text-center">
          <h2>Log in</h2>
          <p className="mt-2 text-sm text-ink-muted">
            Don&apos;t have an account? <Link href="/signup">Sign up</Link>
          </p>
        </div>

        {props.flash?.notice && (
          <p className="mt-4 text-center text-sm text-accent">
            {props.flash.notice}
          </p>
        )}
        {baseError && (
          <p className="mt-4 text-center text-sm text-danger-display">{baseError}</p>
        )}

        <form onSubmit={submit} className="mt-6 space-y-4">
          <div className="space-y-2">
            <label htmlFor="email">Email</label>
            <Input
              id="email"
              type="email"
              autoComplete="email"
              autoFocus
              required
              value={form.data.email}
              onChange={(e) => form.setData("email", e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <label htmlFor="password">Password</label>
            <Input
              id="password"
              type="password"
              autoComplete="current-password"
              required
              value={form.data.password}
              onChange={(e) => form.setData("password", e.target.value)}
            />
          </div>
          <div className="flex flex-col items-center gap-3 pt-2 sm:flex-row sm:justify-between">
            <Button type="submit" disabled={form.processing}>
              Log in
            </Button>
            <Link href="/passwords/new" className="text-sm">
              Forgot password?
            </Link>
          </div>
        </form>
      </AuthShell>
    </>
  )
}
