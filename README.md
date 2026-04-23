# Build New

A blank-slate starter for building full-stack apps with **Rails 8 + Inertia.js + React 19 + PostgreSQL**. TypeScript, Tailwind CSS 4, shadcn/ui (new-york).

Ships with:

- Rails 8 authentication (sessions, signup, password reset)
- Inertia-rendered login, signup, and password-reset pages
- Authenticated app shell: sidebar + header with profile dropdown
- Dashboard, Settings, and Profile pages (profile lets users change email and password)
- System-preference-based dark mode
- Mobile-responsive layouts
- `letter_opener` for previewing mail in development at `/letter_opener`
- Solid Queue, Solid Cache, and Solid Cable consolidated into the primary Postgres database

## Requirements

- Ruby 3.2.0
- Node.js 20.19+ (or 22.12+) for Vite
- PostgreSQL 14+

## Setup

Ensure PostgreSQL is running locally, then:

```bash
bin/setup      # installs gems, creates and migrates the databases
npm install    # installs JS dependencies
bin/dev        # starts Rails (:3000) + Vite (:3036)
```

If your PostgreSQL user/password differs from the defaults (uses your OS user, no password), set:

```bash
export DATABASE_USERNAME=your_pg_user
export DATABASE_PASSWORD=your_pg_password
export DATABASE_HOST=localhost   # optional, defaults to localhost
```

## Opening the database in a GUI

Recommended: [TablePlus](https://tableplus.com/). The database name is derived from the project directory — it's the directory name lowercased, with any non-alphanumerics replaced by `_`, plus a `_development` suffix. You can also confirm the exact name by running `bin/rails runner 'puts ActiveRecord::Base.connection_db_config.database'`, or by reading the `development:` block in `config/database.yml`.

Open it directly by passing the full name to `open`:

```bash
open "postgres://$USER@localhost:5432/your_project_development"
```

Replace `your_project_development` with the actual database name for this project (see `config/database.yml`).

Or detect the name dynamically from the current working directory:

```bash
open "postgres://$USER@localhost:5432/$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g')_development"
```

If you use this across multiple projects, save it as a shell function. Add this to your `~/.zshrc` (or `~/.bashrc`):

```bash
opendb() {
  open "postgres://$USER@localhost:5432/$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g')_development"
}
```

Reload your shell (`source ~/.zshrc`), then run `opendb` from any project root to open that project's development database in TablePlus.

## Commands

```bash
bin/dev                # Rails on :3000 + Vite on :3036
bin/rails test         # Minitest
bin/rails test:system  # Capybara + headless Chrome
npm run check          # TypeScript type checking
bin/rubocop            # Ruby linting
bin/brakeman           # Security scanning
```

## Routes

| Path                      | Purpose                                   |
| ------------------------- | ----------------------------------------- |
| `/`                       | Public landing page (redirects if signed in) |
| `/login`, `/signup`       | Auth                                      |
| `/logout`                 | `DELETE` ends the session                 |
| `/passwords/new`          | Request a password reset                  |
| `/passwords/:token/edit`  | Set a new password from the emailed link  |
| `/dashboard`              | Default signed-in landing page            |
| `/settings`               | Empty settings page                       |
| `/profile`                | Change email / change password            |
| `/letter_opener`          | Sent-mail preview (development only)      |

## Auth

Generated with `bin/rails g authentication` and customized:

- `User` has `email`, `password_digest`, and `timezone`
- Signup reads the browser's IANA timezone (`Intl.DateTimeFormat().resolvedOptions().timeZone`) and stores it on the user
- Password reset emails are sent via Action Mailer (previewable at `/letter_opener` in development)
- Sessions are cookie-backed; `Current.user` is available everywhere, and `current_user` is shared to every Inertia page via `inertia_share` in `ApplicationController`

## Frontend structure

- `app/javascript/pages/` — Inertia page components (resolved by name from controllers)
- `app/frontend/components/` — shared React (shadcn/ui in `ui/`, app shell, auth card)
- `app/frontend/lib/` — utilities (e.g. `cn()`)
- `app/frontend/types/inertia.ts` — typed shared page props (`current_user`, `flash`, `errors`)
- `app/javascript/entrypoints/` — Vite entrypoint (`inertia.ts`) and `application.css`

The `@` path alias resolves to `app/frontend/`.

## Adding a page

1. Add a route in `config/routes.rb`
2. Controller action: `render inertia: "PageName", props: { ... }`
3. Create `app/javascript/pages/PageName.tsx`
4. Wrap authenticated pages in `<AppShell title="...">` from `@/components/app-shell`

## Dark mode

System preference is applied before first paint by an inline script in `app/views/layouts/application.html.erb` that toggles `.dark` on `<html>` based on `prefers-color-scheme`. Tailwind 4's `dark:` variant and the shadcn CSS variables in `app/javascript/entrypoints/application.css` handle the rest.

## Services

Background jobs (Solid Queue), caching (Solid Cache), and WebSockets (Solid Cable) are all database-backed and share the single primary PostgreSQL database. No Redis; no separate `cache`/`cable` databases.

## Deployment

Production expects a `DATABASE_URL` environment variable and a `RAILS_MASTER_KEY`. Any standard Rails deploy target works — Fly.io, Render, Heroku, Kamal, plain VPS, etc. Add a `Dockerfile` if you want one.
