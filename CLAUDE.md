# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repo.

## Tech Stack

Rails 8 + React 19 + PostgreSQL, bridged by **Inertia.js** (no separate API layer). TypeScript, Tailwind CSS 4, shadcn/ui (new-york), Vite 7, Propshaft. Ruby 3.2.0.

Background jobs, caching, and WebSockets use the Rails 8 "Solid" trifecta (Solid Queue, Solid Cache, Solid Cable), all database-backed. **All three share the single primary PostgreSQL database** — there are no separate cache/cable databases, no `db/cache_schema.rb` or `db/cable_schema.rb`, and `config/cache.yml` / `config/cable.yml` have no separate connection blocks.

## Commands

```bash
bin/setup              # Initial setup (bundle, db:prepare, start dev)
bin/dev                # Dev server (Rails :3000 + Vite :3036)
bin/rails test         # Minitest
bin/rails test:system  # Capybara + headless Chrome
npm run check          # TypeScript type checking
bin/rubocop            # Ruby linting (rubocop-rails-omakase)
bin/brakeman           # Security scanning
```

## Architecture

### Inertia.js pattern (no API routes)

Controllers render Inertia responses instead of ERB views:

```ruby
render inertia: "Home", props: { items: @items }
```

The page name resolves to a React component in `app/javascript/pages/` via `app/javascript/entrypoints/inertia.ts` (`import.meta.glob('../pages/**/*.tsx')`).

### Frontend directory layout

- **`app/javascript/`** — Vite source: `entrypoints/`, page components in `pages/`
- **`app/frontend/`** — Shared React code: shadcn/ui in `components/ui/`, app shell in `components/app-shell.tsx`, auth card in `components/auth-card.tsx`, utilities in `lib/`, shared Inertia types in `types/inertia.ts`

The `@` path alias resolves to `app/frontend/` in both Vite and TypeScript configs. Import shared code as `@/components/ui/button`, `@/lib/utils`, `@/types/inertia`.

### Adding a new page

1. Add a route in `config/routes.rb`
2. Controller action calls `render inertia: "PageName", props: { ... }`
3. Create `app/javascript/pages/PageName.tsx`
4. Wrap authenticated pages in `<AppShell title="...">` from `@/components/app-shell`

### Auth

Generated with `bin/rails g authentication` and customized for Inertia:

- Routes: `/login`, `/signup`, `/logout`, `/passwords/new`, `/passwords/:token/edit`
- `User` fields: `email`, `password_digest`, `timezone`
- `SessionsController`, `RegistrationsController`, `PasswordsController` render Inertia pages for `new`/`edit` and redirect on mutations
- `ApplicationController` uses `inertia_share` to expose `current_user`, `flash`, and `errors` on every page
- `Current.user` (`app/models/current.rb`) delegates to `session.user`
- Signup captures the browser's IANA timezone via `Intl.DateTimeFormat().resolvedOptions().timeZone` and stores it on the user

### Mail

`config/environments/development.rb` sets `config.action_mailer.delivery_method = :letter_opener`. The `letter_opener_web` engine is mounted at `/letter_opener` in development only (see `config/routes.rb`). Production mail is not configured — wire up SMTP in `config/environments/production.rb`.

### Dark mode

System preference, via an inline script in `app/views/layouts/application.html.erb` that toggles `.dark` on `<html>` based on `prefers-color-scheme` before first paint. CSS variables in `app/javascript/entrypoints/application.css` define both themes.

### Key files

- `app/javascript/entrypoints/inertia.ts` — React mount point, page resolution
- `app/javascript/entrypoints/application.css` — Tailwind 4 theme (light/dark CSS variables)
- `app/views/layouts/application.html.erb` — Vite client, Inertia entrypoint, dark-mode bootstrap
- `app/controllers/application_controller.rb` — `inertia_share` for shared props
- `app/controllers/concerns/authentication.rb` — session helpers, `require_authentication`
- `config/initializers/inertia_rails.rb` — Inertia config (encrypted history, auto-included errors hash)
- `config/routes.rb` — all routes
- `components.json` — shadcn/ui config

## Inertia controller response rules (common LLM footgun)

**NEVER use `head :ok`, `render json:`, or any non-Inertia response from controller actions called by Inertia's frontend router** (`router.patch`, `router.post`, `router.put`, `router.delete`, `router.get`). Inertia expects one of:

1. **A redirect** — `redirect_to` or `redirect_back` (Inertia follows it and fetches the new page)
2. **An Inertia page render** — `render inertia: "Page", props: { ... }`

A bare `head :ok` or `render json:` returns a 200 with no `X-Inertia` header, which causes the Inertia client to show a blank page or white flash. This is the single most common Inertia bug.

**Pattern for mutation actions (create/update/destroy):**

```ruby
# CORRECT — redirect after a successful mutation
if record.save
  redirect_to records_path, notice: "Saved."
else
  redirect_back(fallback_location: records_path,
                inertia: { errors: record.errors.to_hash(true).transform_values(&:first) })
end

# WRONG — breaks Inertia, causes a blank page
if record.save
  head :ok
else
  render json: { errors: record.errors.to_hash }, status: :unprocessable_entity
end
```

`redirect_to path, inertia: { errors: {...} }` puts errors in the flash, and `config.always_include_errors_hash = true` (see `config/initializers/inertia_rails.rb`) surfaces them as the `errors` prop on every page.

**Exception:** `head :ok` / `render json:` are fine for endpoints called via raw `fetch()` / `XMLHttpRequest` — not via Inertia's router — e.g. background session-saving or `/api` endpoints.

**In tests:** Inertia mutation actions return `302 redirect`, not `200 ok`. Use `assert_response :redirect` for PATCH/PUT/DELETE on web controllers.

## Conventions

- Ruby: `rubocop-rails-omakase` style, `frozen_string_literal: true`
- Tailwind 4 `@theme inline` with CSS custom properties for theming
- `ApplicationController` restricts to modern browsers
- Inertia shared props: `current_user`, `flash`, `errors` on every page (see `@/types/inertia`)
- PostgreSQL is required locally for development and tests
