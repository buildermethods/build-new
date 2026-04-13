import { FormEvent, useEffect } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"

import { AuthCard } from "@/components/auth-card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
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
      <Head title="Sign up" />
      <AuthCard
        title="Create your account"
        subtitle={
          <>
            Already have an account?{" "}
            <Link href="/login" className="font-medium underline underline-offset-4">
              Log in
            </Link>
          </>
        }
      >
        <form onSubmit={submit} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              autoComplete="email"
              required
              aria-invalid={!!errors.email}
              value={form.data.email}
              onChange={(e) => form.setData("email", e.target.value)}
            />
            {errors.email && (
              <p className="text-xs text-destructive">{errors.email}</p>
            )}
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="password">Password</Label>
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
              <p className="text-xs text-destructive">{errors.password}</p>
            )}
          </div>
          <Button type="submit" disabled={form.processing} className="w-full">
            Create account
          </Button>
        </form>
      </AuthCard>
    </>
  )
}
