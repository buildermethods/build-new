# frozen_string_literal: true

require "test_helper"
require "net/http"
require "json"
require "socket"

# Boots the Node SSR server against the built bundle, posts a page payload
# to /render, and asserts the result contains real markup. Catches drift
# between client and SSR entrypoints, broken `noExternal` resolution, and
# browser-globals-at-top-level mistakes that only surface during SSR.
class SsrSmokeTest < ActiveSupport::TestCase
  PORT = 13714
  SSR_BUNDLE = Rails.root.join("public/vite-ssr/ssr.js")
  STARTUP_TIMEOUT = 15

  setup do
    unless Rails.root.join("node_modules").exist?
      flunk "node_modules missing — run `npm install` before running SSR tests"
    end

    if port_in_use?
      flunk "Port #{PORT} is already in use; stop any running `bin/dev-ssr` " \
            "or `npm run ssr` before running this test"
    end

    unless system("bin/vite build --ssr", chdir: Rails.root.to_s)
      flunk "Failed to build SSR bundle — check `bin/vite build --ssr` output"
    end

    @ssr_pid = Process.spawn("node", SSR_BUNDLE.to_s, out: File::NULL, err: File::NULL)

    deadline = Time.now + STARTUP_TIMEOUT
    until port_in_use?
      flunk "SSR server failed to start within #{STARTUP_TIMEOUT}s" if Time.now > deadline
      sleep 0.1
    end
  end

  teardown do
    next unless @ssr_pid
    Process.kill("TERM", @ssr_pid)
    Process.wait(@ssr_pid)
  rescue Errno::ESRCH, Errno::ECHILD
    nil
  end

  test "SSR pipeline renders a known page with real markup and head tags" do
    result = render_page("Home")

    assert_kind_of String, result["body"]
    refute_empty result["body"], "SSR returned an empty body"
    assert_includes result["body"], "Hello world",
                    "Expected SSR-rendered Home page to include 'Hello world'; got: #{result["body"][0, 300]}"

    head = Array(result["head"]).join
    assert_includes head, "<title", "Expected SSR head to include a <title> tag"
  end

  private

  def port_in_use?
    TCPSocket.new("localhost", PORT).close
    true
  rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
    false
  end

  def render_page(component, props = {})
    body = {
      component: component,
      props: {
        current_user: nil,
        flash: { notice: nil, alert: nil },
        errors: {},
        **props
      },
      url: "/",
      version: "test",
      encryptHistory: false,
      clearHistory: false
    }.to_json

    res = Net::HTTP.post(
      URI("http://localhost:#{PORT}/render"),
      body,
      "Content-Type" => "application/json"
    )

    flunk "SSR /render returned #{res.code}: #{res.body[0, 300]}" unless res.is_a?(Net::HTTPSuccess)

    JSON.parse(res.body)
  end
end
