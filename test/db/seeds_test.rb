require "test_helper"
require "minitest/mock"

class SeedsTest < ActiveSupport::TestCase
  %w[production staging test].each do |env|
    test "seeds create no users in #{env}" do
      assert_no_difference -> { User.count } do
        load_seeds_as(env)
      end
    end
  end

  test "seeds create the test logins in development" do
    load_seeds_as("development")

    assert User.exists?(email: "user@test.com", admin: false)
    assert User.exists?(email: "admin@test.com", admin: true)
  end

  private
    def load_seeds_as(env)
      Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new(env)) do
        Rails.application.load_seed
      end
    end
end
