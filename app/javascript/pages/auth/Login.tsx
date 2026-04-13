import { FormEvent } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"

import { AuthCard } from "@/components/auth-card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
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
      <Head title="Log in" />
      <AuthCard
        title="Log in"
        subtitle={
          <>
            Don&apos;t have an account?{" "}
            <Link href="/signup" className="font-medium underline underline-offset-4">
              Sign up
            </Link>
          </>
        }
      >
        {props.flash?.notice && (
          <p className="rounded-md border border-border bg-muted px-3 py-2 text-sm text-muted-foreground">
            {props.flash.notice}
          </p>
        )}
        {baseError && (
          <p className="rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2 text-sm text-destructive">
            {baseError}
          </p>
        )}
        <form onSubmit={submit} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              autoComplete="email"
              required
              value={form.data.email}
              onChange={(e) => form.setData("email", e.target.value)}
            />
          </div>
          <div className="flex flex-col gap-2">
            <div className="flex items-center justify-between">
              <Label htmlFor="password">Password</Label>
              <Link
                href="/passwords/new"
                className="text-xs text-muted-foreground underline underline-offset-4 hover:text-foreground"
              >
                Forgot password?
              </Link>
            </div>
            <Input
              id="password"
              type="password"
              autoComplete="current-password"
              required
              value={form.data.password}
              onChange={(e) => form.setData("password", e.target.value)}
            />
          </div>
          <Button type="submit" disabled={form.processing} className="w-full">
            Log in
          </Button>
        </form>
      </AuthCard>
    </>
  )
}
