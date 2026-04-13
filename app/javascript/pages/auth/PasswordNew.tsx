import { FormEvent } from "react"
import { Head, Link, useForm, usePage } from "@inertiajs/react"

import { AuthCard } from "@/components/auth-card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
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
      <Head title="Reset your password" />
      <AuthCard
        title="Reset your password"
        subtitle="We'll email you a link to set a new password."
      >
        {props.flash?.notice && (
          <p className="rounded-md border border-border bg-muted px-3 py-2 text-sm text-muted-foreground">
            {props.flash.notice}
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
          <Button type="submit" disabled={form.processing} className="w-full">
            Send reset instructions
          </Button>
          <p className="text-center text-sm text-muted-foreground">
            <Link href="/login" className="underline underline-offset-4">
              Back to log in
            </Link>
          </p>
        </form>
      </AuthCard>
    </>
  )
}
