# frozen_string_literal: true

require "test_helper"
require "open3"

# `bin/tableplus --print` resolves the dev connection through Rails (so the ERB
# in config/database.yml and the DATABASE_* overrides are respected) without
# touching the database or launching TablePlus.
class BinTableplusTest < ActiveSupport::TestCase
  def run_tableplus(env = {})
    Open3.capture3(env, "bin/tableplus", "--print", chdir: Rails.root.to_s)
  end

  test "prints a postgresql URL for the derived development database" do
    out, err, status = run_tableplus("DATABASE_NAME" => nil, "DATABASE_URL" => nil)

    assert status.success?, "bin/tableplus --print failed: #{err}"
    uri = URI.parse(out.strip)
    assert_equal "postgresql", uri.scheme
    assert_match(/\A\/[a-z0-9_]+_development(_[a-z0-9_]+)?\z/, uri.path)
  end

  test "honors the DATABASE_NAME override" do
    out, err, status = run_tableplus("DATABASE_NAME" => "tableplus_override_db")

    assert status.success?, "bin/tableplus --print failed: #{err}"
    assert_equal "/tableplus_override_db", URI.parse(out.strip).path
  end
end
