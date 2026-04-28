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
5. Set a descriptive `<Head title>` and `<meta name="description">` on the page (see "Page metadata" below) — required for every page, no exceptions
6. If the page is **publicly viewable** (no `require_authentication`), also:
   - Add it to `config/sitemap.rb` so crawlers discover it
   - Add it to `public/llms.txt` under the right section
   - Make sure it is not blocked in `public/robots.txt`

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
- `app/javascript/entrypoints/ssr.tsx` — SSR mount point (mirrors `inertia.ts` but renders to string)
- `app/javascript/entrypoints/application.css` — Tailwind 4 theme (light/dark CSS variables)
- `app/views/layouts/application.html.erb` — Vite client, Inertia entrypoint, dark-mode bootstrap, `inertia_ssr_head`
- `app/controllers/application_controller.rb` — `inertia_share` for shared props
- `app/controllers/concerns/authentication.rb` — session helpers, `require_authentication`
- `config/initializers/inertia_rails.rb` — Inertia config (encrypted history, auto-included errors hash, SSR)
- `config/routes.rb` — all routes
- `config/sitemap.rb` — sitemap_generator config; lists every public URL
- `public/robots.txt` — crawler allow/deny rules + sitemap pointer
- `public/llms.txt` — curated, plain-text site map for LLM crawlers
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

## Server-side rendering (SSR)

Inertia SSR is wired up so search engines and LLM crawlers (GPTBot, ClaudeBot, PerplexityBot, Google-Extended, etc.) receive fully rendered HTML instead of an empty `<div id="app">` populated only by client-side JavaScript. Without SSR, public pages are effectively invisible to non-JS crawlers.

**How it works.** When SSR is enabled, the Rails request handler POSTs the page name + props to a long-running Node process (default `http://localhost:13714`). That process runs `app/javascript/entrypoints/ssr.tsx`, renders the React tree with `ReactDOMServer.renderToString`, and returns the HTML + `<head>` tags. Rails inlines them via `<%= inertia_ssr_head %>` and the rendered markup in `app/views/layouts/application.html.erb`. The client-side bundle then hydrates on top of that markup.

**Configuration.**

- `config/initializers/inertia_rails.rb` — `ssr_enabled` is on in production by default, off in development. Override with `INERTIA_SSR=1` (force on) or `INERTIA_SSR=0` (force off).
- `vite.config.ts` — `ssr: { noExternal: true }` bundles all dependencies into the SSR output so the Node process boots without needing `node_modules` resolution at runtime.
- `package.json` — `npm run build:ssr` produces `public/vite-ssr/ssr.js`; `npm run ssr` runs it.

**Local SSR testing (recommended after touching pages, the layout, or shared components).**

1. `npm run build:ssr`
2. In a second terminal: `npm run ssr`
3. Start Rails with `INERTIA_SSR=1 bin/dev`
4. Load a page and view source — the `<div id="app">` should contain real markup, not an empty container.

A commented `ssr_build` + `ssr` block in `Procfile.dev` automates steps 1–2 if uncommented.

**Production checklist.** The deploy pipeline must:

1. Run `npm run build` (client bundle) **and** `npm run build:ssr` (SSR bundle).
2. Start the Node SSR process (`node public/vite-ssr/ssr.js`) alongside Rails — typically as a separate Procfile entry, container sidecar, or systemd unit. If the SSR process is unreachable, Inertia falls back to an empty `<div id="app">` and crawlers see nothing.

**Keeping SSR working.**

- Anything imported by a page component runs in Node during SSR. **Never reference `window`, `document`, `localStorage`, or other browser-only globals at module top-level or during render.** Guard with `typeof window !== "undefined"` or move the access into a `useEffect`.
- Don't add code paths in `inertia.ts` (client) without mirroring them in `ssr.tsx` if they affect rendered output (e.g. shared providers, default layouts). The two entrypoints must produce the same component tree.
- Avoid randomness, `Date.now()`, and other non-deterministic values during render — they cause hydration mismatches.
- After adding heavy native deps, re-run `npm run build:ssr` locally; if it fails because of an ESM/CJS issue, add the offending package to `ssr.noExternal` exceptions in `vite.config.ts` (or leave `noExternal: true` and pin the package version that works).

## Crawler discovery: sitemap.xml, robots.txt, llms.txt

Three discovery files live at the site root and must stay in sync as public pages are added or removed:

**`config/sitemap.rb` → `public/sitemap.xml`** (sitemap_generator gem). Regenerate with `bin/rails sitemap:refresh:no_ping` (writes the file) or `bin/rails sitemap:refresh` (writes + pings search engines). The host comes from `APP_HOST` env var, falling back to `Rails.application.config.action_controller.default_url_options[:host]`. **Whenever a publicly viewable route is added, removed, or has its URL changed, update `config/sitemap.rb` accordingly and regenerate.** Auth-gated routes must not appear here.

**`public/robots.txt`** — explicitly allows all user-agents and lists the auth-gated route prefixes (`/login`, `/dashboard`, `/profile`, etc.) under `Disallow:`. Also contains a `Sitemap:` line pointing at `https://example.com/sitemap.xml` — change that host on first deploy of each app forked from this template. **When new auth-gated route prefixes are added, add matching `Disallow:` lines** so they aren't crawled.

**`public/llms.txt`** — a curated, hand-maintained markdown index of public pages, following the [llmstxt.org](https://llmstxt.org) convention. LLM crawlers ingest this directly and prefer it over scraping rendered HTML. **Whenever a public page is added, removed, or significantly retitled, update `public/llms.txt` to match** — slot it into the appropriate section (Main pages / About / Product / Resources) with a one-line description. Keep the entries scoped to publicly viewable pages only.

## Page metadata (every page, no exceptions)

Every page component in `app/javascript/pages/` must set both a descriptive title and a meta description via Inertia's `<Head>`:

```tsx
import { Head } from "@inertiajs/react"

export default function Pricing() {
  return (
    <>
      <Head title="Pricing">
        <meta
          name="description"
          content="Plans, pricing, and what's included in each tier of <Product Name>."
        />
      </Head>
      {/* ...page content... */}
    </>
  )
}
```

**Rules.**

- **Title:** specific to the page — not the app name (the app name is appended by `app/javascript/entrypoints/inertia.ts` if a `title` callback is configured there). Keep under ~60 characters so it doesn't get truncated in search results.
- **Description:** unique per page, written for humans, 120–160 characters, summarizes what the page is and why someone would land on it. Avoid keyword stuffing.
- Public marketing pages (home, pricing, about, blog, docs, etc.) are crawled — these descriptions show up directly in search results and AI answers, so they matter most.
- Authenticated pages still need them — they're disallowed in `robots.txt` but the title/description shows up in browser tabs, history, and link previews.
- For social sharing on a public page, also add `og:title`, `og:description`, `og:image`, and `twitter:card` meta tags inside the same `<Head>`.

`app/javascript/pages/Home.tsx` is the canonical example to copy from.

## Conventions

- Ruby: `rubocop-rails-omakase` style, `frozen_string_literal: true`
- Tailwind 4 `@theme inline` with CSS custom properties for theming
- `ApplicationController` restricts to modern browsers
- Inertia shared props: `current_user`, `flash`, `errors` on every page (see `@/types/inertia`)
- PostgreSQL is required locally for development and tests
