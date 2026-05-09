# Changelog

Versions are numbered using the release date in `YYYY.MM.DD` format.

## 2026.5.9

- Switched the database from SQLite back to PostgreSQL. Single database at `build_new_<env>` is shared by Active Record and the Solid trifecta (Queue, Cache, Cable). Connection is configurable via `DATABASE_URL` or the `DATABASE_USER` / `DATABASE_PASSWORD` / `DATABASE_HOST` / `DATABASE_PORT` env vars.
- Added `admin` boolean column to users (default `false`) and an `/admin` namespace gated by `Admin::BaseController` (admins only). Added admin Users index + show pages and a Shield-icon Admin link in the user menu when `current_user.admin` is true.

## 2026.5.8

Reset to a true blank slate.

- Replaced PostgreSQL with SQLite. Single database at `storage/<env>.sqlite3` is shared by Active Record and the Solid trifecta (Queue, Cache, Cable).
- Removed Tailwind CSS, shadcn/ui, `tw-animate-css`, Radix primitives, `lucide-react`, `class-variance-authority`, `clsx`, `tailwind-merge`, `cn()` utility, and `components.json`.
- Removed the authenticated `AppShell` (sidebar + header dropdown) and the `AuthCard` wrapper.
- Removed the system-preference dark-mode bootstrap and CSS theme variables.
- All pages are now plain unstyled HTML — pick a UI approach per app.

## 2026.4.27

Initial release.

- Rails 8 + Inertia.js + React 19 starter on PostgreSQL
- TypeScript, Tailwind CSS 4, shadcn/ui (new-york), Vite 7
- Authentication with sessions, signup, and password reset (Inertia-rendered)
- Authenticated app shell: sidebar + header with profile dropdown
- Dashboard, Settings, and Profile pages (email + password change from Profile)
- Signup captures the browser's IANA timezone and stores it on the user
- System-preference-based dark mode applied before first paint
- Mobile-responsive layouts
- `letter_opener` for previewing mail in development at `/letter_opener`
- Solid Queue, Solid Cache, and Solid Cable consolidated into the primary Postgres database (no Redis, no separate cache/cable databases)
- Per-clone database name derived from the project directory, so cloning the GitHub template gives each project its own Postgres database
- `bin/setup` → `npm install` → `bin/dev` flow for fresh template clones
