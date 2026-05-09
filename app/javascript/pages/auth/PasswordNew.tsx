import { FormEvent } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"
import { AuthShell } from "@/components/AuthShell"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

import type { PageProps } from "@/types/inertia"

export default function PasswordNew() {
  const { props } = usePage<PageProps>()
  const form = useForm({ email: "" })

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.post("/passwords")
  }

  return (
    <>
      <Head title="Reset your password">
        <meta name="description" content="Request a password reset link by email." />
        <meta property="og:title" content="Reset your password" />
        <meta property="og:description" content="Request a password reset link by email." />
      </Head>
      <AuthShell>
        <h1>Reset your password</h1>
        <p className="mt-2">We&apos;ll email you a link to set a new password.</p>

        {props.flash?.notice && (
          <p className="mt-4 text-sm text-accent">{props.flash.notice}</p>
        )}

        <form onSubmit={submit} className="mt-6 space-y-4">
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
              value={form.data.email}
              onChange={(e) => form.setData("email", e.target.value)}
            />
          </div>
          <Button type="submit" disabled={form.processing}>
            Send reset instructions
          </Button>
        </form>

        <p className="mt-6">
          <Link href="/login">Back to log in</Link>
        </p>
      </AuthShell>
    </>
  )
}
