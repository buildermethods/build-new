# frozen_string_literal: true

# Sitemap configuration for sitemap_generator.
#
# Refresh the sitemap with:
#   bin/rails sitemap:refresh           (also pings search engines)
#   bin/rails sitemap:refresh:no_ping   (just writes public/sitemap.xml)
#
# IMPORTANT: every publicly viewable page must be added below. Anything
# behind authentication should be excluded — crawlers cannot reach it
# and listing it leaks routes. The root path is included automatically.

SitemapGenerator::Sitemap.default_host =
  ENV.fetch("APP_HOST") { Rails.application.config.action_controller&.default_url_options&.dig(:host) || "https://example.com" }

# Write the generated sitemap.xml(.gz) into public/ so it is served
# directly by the web server at /sitemap.xml.
SitemapGenerator::Sitemap.public_path = "public/"
SitemapGenerator::Sitemap.sitemaps_path = ""
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  # The root path is added by sitemap_generator automatically.
  #
  # Add additional public pages here as the app grows. Examples:
  #   add about_path,   changefreq: "monthly", priority: 0.8
  #   add pricing_path, changefreq: "monthly", priority: 0.9
  #   add help_path,    changefreq: "weekly"
  #
  # For dynamic content, iterate the records:
  #   Post.published.find_each do |post|
  #     add post_path(post), lastmod: post.updated_at
  #   end
end
