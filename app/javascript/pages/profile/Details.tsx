import { FormEvent } from "react"
import { Head, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { ProfileSubNav } from "./ProfileSubNav"

import type { PageProps } from "@/types/inertia"

export default function ProfileDetails() {
  const { props } = usePage<PageProps>()
  const user = props.current_user
  const errors = props.errors ?? {}

  const emailForm = useForm({ email: user?.email ?? "" })

  const submit = (e: FormEvent) => {
    e.preventDefault()
    emailForm.patch("/profile/email", { preserveScroll: true })
  }

  return (
    <>
      <Head title="My details">
        <meta name="description" content="Update the email address you use to log in." />
        <meta property="og:title" content="My details" />
        <meta property="og:description" content="Update the email address you use to log in." />
      </Head>
      <AppShell>
        <PageHeader
          title="Profile"
          description="Manage your account."
          tabs={<ProfileSubNav active="details" />}
        />

        {props.flash?.notice && (
          <p className="mt-6 text-sm text-accent">{props.flash.notice}</p>
        )}

        <section className="mt-10 max-w-md">
          <form onSubmit={submit} className="space-y-4">
            <div className="space-y-2">
              <label
                htmlFor="email"
                className="block text-sm font-medium text-ink-display"
              >
                Email
              </label>
              <Input
                id="email"
                type="email"
                autoComplete="email"
                required
                aria-invalid={!!errors.email}
                value={emailForm.data.email}
                onChange={(e) => emailForm.setData("email", e.target.value)}
              />
              {errors.email && (
                <p className="text-xs text-signal">{errors.email}</p>
              )}
            </div>
            <Button type="submit" disabled={emailForm.processing}>
              Update email
            </Button>
          </form>
        </section>
      </AppShell>
    </>
  )
}
