import { FormEvent } from "react"
import { Head, useForm, usePage } from "@inertiajs/react"

import { AppShell } from "@/components/app-shell"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import type { PageProps } from "@/types/inertia"

export default function Profile() {
  const { props } = usePage<PageProps>()
  const user = props.current_user
  const errors = props.errors ?? {}

  const emailForm = useForm({ email: user?.email ?? "" })
  const passwordForm = useForm({ current_password: "", password: "" })

  const submitEmail = (e: FormEvent) => {
    e.preventDefault()
    emailForm.patch("/profile/email", { preserveScroll: true })
  }

  const submitPassword = (e: FormEvent) => {
    e.preventDefault()
    passwordForm.patch("/profile/password", {
      preserveScroll: true,
      onSuccess: () => passwordForm.reset(),
    })
  }

  return (
    <>
      <Head title="Profile" />
      <AppShell title="Profile">
        <div className="mx-auto flex max-w-2xl flex-col gap-10">
          <div>
            <h2 className="text-2xl font-semibold tracking-tight">Profile</h2>
            <p className="text-sm text-muted-foreground">
              Manage your email address and password.
            </p>
          </div>

          {props.flash?.notice && (
            <p className="rounded-md border border-border bg-muted px-3 py-2 text-sm text-muted-foreground">
              {props.flash.notice}
            </p>
          )}

          <section className="space-y-4 rounded-lg bg-muted p-6">
            <div className="space-y-1">
              <h3 className="text-base font-medium">Email</h3>
              <p className="text-sm text-muted-foreground">
                Change the email address used to log in.
              </p>
            </div>
            <form onSubmit={submitEmail} className="flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  autoComplete="email"
                  required
                  aria-invalid={!!errors.email}
                  value={emailForm.data.email}
                  onChange={(e) =>
                    emailForm.setData("email", e.target.value)
                  }
                />
                {errors.email && (
                  <p className="text-xs text-destructive">
                    {errors.email}
                  </p>
                )}
              </div>
              <div>
                <Button type="submit" disabled={emailForm.processing}>
                  Update email
                </Button>
              </div>
            </form>
          </section>

          <section className="space-y-4 rounded-lg bg-muted p-6">
            <div className="space-y-1">
              <h3 className="text-base font-medium">Password</h3>
              <p className="text-sm text-muted-foreground">
                Enter your current password to set a new one.
              </p>
            </div>
            <form onSubmit={submitPassword} className="flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <Label htmlFor="current_password">Current password</Label>
                <Input
                  id="current_password"
                  type="password"
                  autoComplete="current-password"
                  required
                  aria-invalid={!!errors.current_password}
                  value={passwordForm.data.current_password}
                  onChange={(e) =>
                    passwordForm.setData("current_password", e.target.value)
                  }
                />
                {errors.current_password && (
                  <p className="text-xs text-destructive">
                    {errors.current_password}
                  </p>
                )}
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="password">New password</Label>
                <Input
                  id="password"
                  type="password"
                  autoComplete="new-password"
                  required
                  aria-invalid={!!errors.password}
                  value={passwordForm.data.password}
                  onChange={(e) =>
                    passwordForm.setData("password", e.target.value)
                  }
                />
                {errors.password && (
                  <p className="text-xs text-destructive">{errors.password}</p>
                )}
              </div>
              <div>
                <Button type="submit" disabled={passwordForm.processing}>
                  Update password
                </Button>
              </div>
            </form>
          </section>
        </div>
      </AppShell>
    </>
  )
}
