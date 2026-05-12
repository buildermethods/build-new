# Hatchbox deployment guide

Quick reference for deploying an app generated from this template to Hatchbox. Steps are in the order you'd do them in the Hatchbox UI.

## 1. Spin up a cluster (server)

Create a new cluster in Hatchbox — typically on Digital Ocean. The cluster needs these roles:

- **Web** — Rails app + the SSR Node process
- **Worker** — Solid Queue background jobs (`bin/jobs`)
- **Cron** — scheduled jobs (only needed if you add any; safe to include by default)
- **PostgreSQL** — the single database that backs Active Record, Solid Queue, Solid Cache, and Solid Cable

A single-server cluster with all roles is fine for a small app. Split them later if you outgrow it.

Make sure the server image has compatible Ruby and Node versions — this app expects:

- Ruby `3.3.6` (from `.ruby-version`)
- Node `22.12.0` (from `.nvmrc`)

## 2. Create the app

- Hatchbox dashboard → New App
- Connect your GitHub repo and pick the branch to deploy (e.g. `main` or `staging`)
- (Optional) Enable auto-deploy on push for that branch

## 3. Set environment variables

App → **Environment**. At minimum:

| Variable | Value | Notes |
| --- | --- | --- |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` (or `config/credentials/production.key` if you've set up environment-scoped credentials) | Required. Do **not** commit the key file. |
| `APP_HOST` | `https://yourdomain.com` | Used by `config/sitemap.rb` to build absolute URLs in `public/sitemap.xml`. Without it, the sitemap falls back to `https://example.com`. |

Optional / situational:

| Variable | Value | When to set it |
| --- | --- | --- |
| `INERTIA_SSR` | `1` or `0` | SSR is **on by default in production** (see `config/initializers/inertia_rails.rb`). Set `0` to force-disable, e.g. for debugging. |
| `INERTIA_SSR_URL` | `http://localhost:13714` | Only needed if you move the SSR process to a non-default port. |
| `DATABASE_URL` | postgres URL | Hatchbox usually sets this automatically when you attach the database (step 4). Only override if you're pointing at an external database. |

## 4. Create the database

App → **Databases** → click the button to create a PostgreSQL database for this app. Hatchbox provisions it on the PostgreSQL-role server and wires `DATABASE_URL` into the app automatically.

This single database is also used by Solid Queue, Solid Cache, and Solid Cable — no separate databases needed (see `CLAUDE.md`).

## 5. Set up the domain

App → **Domains & SSL**:

- Add your domain (e.g. `yourdomain.com` and/or `www.yourdomain.com`)
- Point DNS at the Hatchbox server IP (A record for apex, CNAME for `www`)
- Let Hatchbox auto-provision Let's Encrypt SSL once DNS propagates

## 6. Create the SSR process

App → **Processes** → Add Process. This runs the long-lived Node server that handles Inertia SSR requests from Rails.

| Field | Value |
| --- | --- |
| Runs on | **web** |
| Process name | `ssr` |
| Start command | `bin/vite ssr` |
| Reload command | *(empty)* |
| Stop command | *(empty)* |
| Restart this process on every deploy | ✅ checked |
| Socket activation | unchecked |

**Why this matters:** the Inertia Rails renderer POSTs page renders to this Node process at `http://localhost:13714`. If the process isn't running, Inertia silently falls back to client-only rendering — crawlers (Google, GPTBot, ClaudeBot, etc.) see an empty `<div id="app">` on public pages.

The SSR bundle itself (`public/vite-ssr/ssr.js`) is built automatically during `assets:precompile` because `config/vite.json` has `"ssrBuildEnabled": true`. No extra build step needed.

## 7. Create the jobs process

App → **Processes** → Add Process. This runs Solid Queue.

| Field | Value |
| --- | --- |
| Runs on | **worker** |
| Process name | `jobs` |
| Start command | `bin/jobs` |
| Restart this process on every deploy | ✅ checked |

## 8. Deploy

App → **Deploy**. Hatchbox will:

1. Pull the latest commit
2. Run `bundle install` and `npm install` (or `bun install`)
3. Run `assets:precompile` — produces both `public/vite/` (client) and `public/vite-ssr/ssr.js` (SSR)
4. Run `db:prepare` (migrations + seeds on first deploy)
5. Boot the web process + restart the `ssr` and `jobs` processes

## Post-deploy checks

- Visit the site and **view source** on a public page — `<div id="app">` should contain rendered HTML, not be empty. If it's empty, SSR isn't reaching the Node process (check the `ssr` process logs in Hatchbox).
- Visit `/sitemap.xml` (after deploy + sitemap regen) — URLs should use your real domain, not `example.com`. If they don't, `APP_HOST` isn't set.
- Update `public/robots.txt` so the `Sitemap:` line points at your real domain (it ships pointing at `https://example.com/sitemap.xml`).
- Trigger a background job to confirm Solid Queue is processing — check the `jobs` process logs.

## Troubleshooting

**Blank page / empty `<div id="app">` in view source.** SSR Node process isn't running or isn't reachable. Check the `ssr` process logs. Confirm `public/vite-ssr/ssr.js` exists in the deployed release (it should, after the `ssrBuildEnabled` fix).

**`ActiveRecord::ConnectionNotEstablished` or queue/cache errors.** The single PostgreSQL DB powers all four (Active Record + Solid Queue/Cache/Cable). Make sure `DATABASE_URL` is set and the DB was provisioned in step 4.

**`Missing secret_key_base` or credentials errors.** `RAILS_MASTER_KEY` not set or doesn't match the encrypted credentials file in the repo.

**Sitemap shows `example.com` URLs.** `APP_HOST` env var not set.
