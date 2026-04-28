# frozen_string_literal: true

InertiaRails.configure do |config|
  config.version = ViteRuby.digest
  config.encrypt_history = true
  config.always_include_errors_hash = true

  # Server-side rendering. Inertia POSTs the page name + props to the SSR
  # Node process (default port 13714) which returns rendered HTML so search
  # engines and LLM crawlers see real content, not an empty <div id="app">.
  # Enabled in production by default; opt in locally with INERTIA_SSR=1
  # after running `npm run build:ssr` and then `npm run ssr`.
  config.ssr_enabled = ENV.fetch("INERTIA_SSR") { Rails.env.production? ? "1" : "0" } == "1"
  config.ssr_url = ENV.fetch("INERTIA_SSR_URL", "http://localhost:13714")
end
