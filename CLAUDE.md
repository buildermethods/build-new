# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repo.

## Tech Stack

Rails 8 + React 19 + PostgreSQL, bridged by **Inertia.js** (no separate API layer). TypeScript, Vite 7, Propshaft. Ruby 3.3.6.

**Tailwind CSS v4** is wired up via `@tailwindcss/vite`. The app has a complete design system (tokens, primitives, dark-mode theming, the `cn()` utility, shared components under `app/frontend/components/`) — see the "Design system" section below and the live reference at `/admin/design-system`.

Background jobs, caching, and WebSockets use the Rails 8 "Solid" trifecta (Solid Queue, Solid Cache, Solid Cable), all database-backed. **All four share the single PostgreSQL database** (`<app_name>_<env>`, where `app_name` is the repo's folder name — `build_new` for this template) — there are no separate cache/cable/queue databases, no `db/cache_schema.rb` / `db/cable_schema.rb` / `db/queue_schema.rb`, and `config/cache.yml` / `config/cable.yml` / `config/queue.yml` have no separate connection blocks. Override the connection via `DATABASE_URL` or the `DATABASE_USER` / `DATABASE_PASSWORD` / `DATABASE_HOST` / `DATABASE_PORT` env vars (see `config/database.yml`).

**Per-app, per-worktree DB naming.** `config/database.yml` derives the development *and* test DB names automatically, so an app forked from this template gets its own databases with no edits to the file. The name has two parts: an `app_name` (the repository's own folder name, sanitized to a legal Postgres identifier — `coolapp`, or `build-new` → `build_new`) and a worktree suffix. In the **main checkout** (where `.git` is a directory) the suffix is empty: `<app_name>_development` / `<app_name>_test`. In a **git worktree** (where `.git` is a pointer file written by `git worktree add`, e.g. Conductor workspaces) the worktree's own folder name is appended — `<app_name>_development_<worktree>` / `<app_name>_test_<worktree>` — so parallel worktrees never share or clobber each other's schemas, and parallel `bin/rails test` runs no longer collide on a shared test DB. `app_name` is found from the main repo even inside a worktree: the worktree's `.git` pointer (`gitdir: <repo>/.git/worktrees/<wt>`) is read and walked up to the main repo root, whose folder name becomes `app_name`. This matters when forking this template into a new app: if two checkouts shared a dev DB, migrations from one would land in the other and `db:schema:dump` would commit phantom tables. Override the development name entirely with `DATABASE_NAME`. Staging/production are named the same way but are overridden by `DATABASE_URL` on real deploys, so the derived name there is only a local fallback.

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
- **`app/frontend/`** — Shared React code: `types/inertia.ts`, the design system under `components/design-system/` and `components/ui/`, helpers under `lib/`, and the design-system stylesheet under `styles/`.

The `@` path alias resolves to `app/frontend/` in both Vite and TypeScript configs. Import shared code as `@/types/inertia`, `@/components/ui/button`, `@/lib/utils`, etc.

### Adding a new page

1. Add a route in `config/routes.rb`
2. Controller action calls `render inertia: "PageName", props: { ... }`
3. Create `app/javascript/pages/PageName.tsx`
4. Set `<Head title>`, `<meta name="description">`, `<meta property="og:title">`, and `<meta property="og:description">` on the page (see "Page metadata" below) — required for every page, no exceptions
5. If the page is **publicly viewable** (no `require_authentication`), also:
   - Add it to `config/sitemap.rb` so crawlers discover it
   - Add it to `public/llms.txt` under the right section
   - Make sure it is not blocked in `public/robots.txt`

### Key files

- `app/javascript/entrypoints/inertia.ts` — React mount point, page resolution
- `app/javascript/ssr/ssr.tsx` — SSR mount point (mirrors `inertia.ts` but renders to string); auto-detected by vite-plugin-ruby
- `app/javascript/entrypoints/application.css` — Tailwind import, `@source` directive, and the design-system stylesheet import
- `app/views/layouts/application.html.erb` — Vite client, Inertia entrypoint, `inertia_ssr_head`
- `app/controllers/application_controller.rb` — `inertia_share` for shared props
- `app/controllers/concerns/authentication.rb` — session helpers, `require_authentication`
- `config/initializers/inertia_rails.rb` — Inertia config (encrypted history, auto-included errors hash, SSR)
- `config/routes.rb` — all routes
- `config/sitemap.rb` — sitemap_generator config; lists every public URL
- `public/robots.txt` — crawler allow/deny rules + sitemap pointer
- `public/llms.txt` — curated, plain-text site map for LLM crawlers

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

**How it works.** When SSR is enabled, the Rails request handler POSTs the page name + props to a long-running Node process (default `http://localhost:13714`). That process runs the SSR bundle built from `app/javascript/ssr/ssr.tsx`, renders the React tree with `ReactDOMServer.renderToString`, and returns the HTML + `<head>` tags. Rails inlines them via `<%= inertia_ssr_head %>` and the rendered markup in `app/views/layouts/application.html.erb`. The client-side bundle then hydrates on top of that markup.

**Configuration.**

- `config/initializers/inertia_rails.rb` — `ssr_enabled` is on in production by default, off in development. Override with `INERTIA_SSR=1` (force on) or `INERTIA_SSR=0` (force off).
- `vite.config.ts` — `ssr: { noExternal: true }` bundles all dependencies into the SSR output so the Node process boots without needing `node_modules` resolution at runtime.
- `bin/vite build --ssr` produces `public/vite-ssr/ssr.js` (vite-plugin-ruby's default SSR output path); `bin/vite ssr` runs it.

**Local SSR testing.** Run `bin/dev-ssr` instead of `bin/dev`. It builds the SSR bundle, sets `INERTIA_SSR=1`, and runs Rails + Vite + Solid Queue + an SSR build watcher + the Node SSR server together via `Procfile.ssr`. View source on a page — the `<div id="app">` should contain real markup, not an empty container.

**SSR smoke test.** `bin/rails test test/integration/ssr_smoke_test.rb` builds the SSR bundle, boots the Node server, hits `/render`, and asserts non-empty markup. It also runs as part of `bin/rails test`. Use it to catch breakage from changes to entrypoints, shared providers, or anything imported during SSR.

Production deployment is host-specific (Render, Fly, Heroku, container, bare metal, etc.) and not prescribed here. The Inertia Rails renderer silently falls back to a client-only render if the SSR Node process is unreachable, so the smoke test is your guardrail — keep it green and the SSR pipeline works.

**Keeping SSR working.**

- Anything imported by a page component runs in Node during SSR. **Never reference `window`, `document`, `localStorage`, or other browser-only globals at module top-level or during render.** Guard with `typeof window !== "undefined"` or move the access into a `useEffect`.
- Don't add code paths in `inertia.ts` (client) without mirroring them in `ssr.tsx` if they affect rendered output (e.g. shared providers, default layouts). The two entrypoints must produce the same component tree.
- Avoid randomness, `Date.now()`, and other non-deterministic values during render — they cause hydration mismatches.
- After adding heavy native deps, re-run `bin/vite build --ssr` locally; if it fails because of an ESM/CJS issue, add the offending package to `ssr.noExternal` exceptions in `vite.config.ts` (or leave `noExternal: true` and pin the package version that works).

## Crawler discovery: sitemap.xml, robots.txt, llms.txt

Three discovery files live at the site root and must stay in sync as public pages are added or removed:

**`config/sitemap.rb` → `public/sitemap.xml`** (sitemap_generator gem). Regenerate with `bin/rails sitemap:refresh:no_ping` (writes the file) or `bin/rails sitemap:refresh` (writes + pings search engines). The host comes from `APP_HOST` env var, falling back to `Rails.application.config.action_controller.default_url_options[:host]`. **Whenever a publicly viewable route is added, removed, or has its URL changed, update `config/sitemap.rb` accordingly and regenerate.** Auth-gated routes must not appear here.

**`public/robots.txt`** — explicitly allows all user-agents and lists the auth-gated route prefixes (`/login`, `/dashboard`, `/profile`, etc.) under `Disallow:`. Also contains a `Sitemap:` line pointing at `https://example.com/sitemap.xml` — change that host on first deploy of each app forked from this template. **When new auth-gated route prefixes are added, add matching `Disallow:` lines** so they aren't crawled.

**`public/llms.txt`** — a curated, hand-maintained markdown index of public pages, following the [llmstxt.org](https://llmstxt.org) convention. LLM crawlers ingest this directly and prefer it over scraping rendered HTML. **Whenever a public page is added, removed, or significantly retitled, update `public/llms.txt` to match** — slot it into the appropriate section (Main pages / About / Product / Resources) with a one-line description. Keep the entries scoped to publicly viewable pages only.

## Page metadata (every page, no exceptions)

Every page component in `app/javascript/pages/` must set, inside Inertia's `<Head>`, **all four** of: title, meta description, `og:title`, and `og:description`. Title + description drive search and accessibility; the `og:` tags drive social previews (Slack, Discord, X, LinkedIn, iMessage). Without explicit `og:` tags, social platforms fall back to `<title>` + `<meta name="description">` — which works, but doesn't let you tune the social-specific copy independently.

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
        <meta property="og:title" content="Pricing" />
        <meta
          property="og:description"
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
- **`og:title` + `og:description`:** mirror title and description by default. Override only when the social-share copy should differ from the search-result copy (e.g. punchier headline, more conversion-focused).
- Public marketing pages (home, pricing, about, blog, docs, etc.) are crawled — these tags show up directly in search results, AI answers, and link previews, so they matter most.
- Authenticated pages still need them — they're disallowed in `robots.txt` but the title/description shows up in browser tabs, history, and link previews when someone shares an internal link.
- For richer social previews on a public page, also add `og:image` (1200×630), `og:type`, and `twitter:card="summary_large_image"` inside the same `<Head>`.

`app/javascript/pages/Home.tsx` is the canonical example to copy from.

## Conventions

- Ruby: `rubocop-rails-omakase` style, `frozen_string_literal: true`
- Tailwind CSS v4 + a complete design system (tokens, primitives, dark mode) — see the "Design system" section below and `/admin/design-system`
- `ApplicationController` restricts to modern browsers
- Inertia shared props: `current_user`, `flash`, `errors` on every page (see `@/types/inertia`)
- PostgreSQL (database `<app_name>_<env>`, derived from the repo's folder name — `build_new` for this template) is the only database — Active Record + Solid Queue/Cache/Cable all share it

<!-- bm-design-system:start -->
## Design system

This codebase has a design system documented at [`/admin/design-system`](/admin/design-system). The page previews and explains every primitive — colors, typography, structure, base styles, and elements — and shows the exact markup to use.

When implementing UI:

1. **Always check the design system first.** Before writing any frontend markup or styles, refer to `/admin/design-system` and the components under `components/ui/` and `components/design-system/sections/`. Use the existing tokens (`bg-page`, `bg-surface`, `text-ink-body`, etc.) and the existing primitives (`<Button>`, `<Input>`, `<Badge>`, `<Select>`, `<Checkbox>`, `<Radio>`, `<RichTextField>`, `<Dialog>`, `<ThemeToggle>` and friends).

2. **Do not invent ad-hoc styles.** Don't reach for raw hex values, raw font sizes, or one-off Tailwind utilities when a token or primitive exists. Don't introduce new variant systems alongside the existing `cva`-based ones.

3. **Use bare semantic HTML for text elements.** Headings (`<h1>`–`<h6>`), paragraphs (`<p>`), anchors (`<a>`), `<strong>`, `<blockquote>`, `<ul>` / `<ol>` / `<li>`, `<hr>`, and form-field labels (`<label htmlFor>` / `<legend>`) already have their size, color, weight, font, letter-spacing, and line-height defined in the base layer of `design-system.css`. **Do not apply Tailwind utilities like `text-xl`, `text-2xl`, `text-sm`, `font-semibold`, `font-medium`, `text-ink-display`, `text-ink-muted`, `tracking-tight`, `leading-tight` to these elements** — write `<h1>Projects</h1>`, not `<h1 className="text-2xl font-semibold text-ink-display">Projects</h1>`, and write `<label htmlFor="email">Email</label>`, not `<label htmlFor="email" className="text-sm font-medium text-ink-display">Email</label>`. Page headers in particular use `<h1>` (not `<h2>`) at the design system's base h1 size. Layout utilities (`mt-1`, `mb-4`, `max-w-md`, `flex`, etc.) are fine. If a usage genuinely needs different text styling, propose adding it to the design system as a class or element variant rather than overriding inline. The base rule applies to all `<label>` and `<legend>` elements; for the special case of a label used as a wrapper around a checkbox/radio (where the visible text is body copy, not a field title), add `font-normal text-ink-body` to override the medium weight and display color.

4. **If a needed UI element is missing, propose it as a design-system addition** before building a one-off. Ask the user something like: "There's no existing primitive for X. Want me to add it to the design system (`components/ui/x.tsx` + a new section on `/admin/design-system`) so it stays consistent, or do a one-off here?" Default to proposing the system addition.

5. **Re-running the `bm-design-system` skill** is the supported way to add new sections or update tokens. It detects existing setup and merges non-destructively.

### Styling pipeline

**Tailwind CSS v4** is wired up via `@tailwindcss/vite` in `vite.config.ts`. `app/javascript/entrypoints/application.css` imports the framework and then imports the design-system stylesheet (`app/frontend/styles/design-system.css`), which defines the `@theme` block (color + font tokens) and the base layer. The layout loads the bundle with `vite_stylesheet_tag "application"`.

Source files are declared explicitly via an `@source` directive in `application.css` (Tailwind v4 has auto-detection, but it doesn't reliably pick up the split between `app/javascript/` and `app/frontend/` in this setup, so we declare them explicitly). Don't remove the `@source` line — classes used only inside `app/frontend/components/**` will silently fail to emit if you do.
<!-- bm-design-system:end -->

## Testing and verification

- **After implementing a significant feature, ensure we have test coverage for that feature** and that the full test suite still passes 100%. Run `bin/rails test` (and `bin/rails test:system` for system tests) before reporting the task as complete.
- **When making any front-end UI changes or features, verify with the `agent-browser` skill** that all user paths and flows actually work end-to-end and remain accessible.
- **For new pages, new layouts, or significant UI changes, take a screenshot and evaluate your own work** — confirm styling, design, visual balance, and responsiveness (desktop + mobile widths) are executed correctly. Store these verification screenshots in `tmp/screenshots/` so they're easy to find and don't pollute the repo.
