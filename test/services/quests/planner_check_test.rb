require "test_helper"
require "rake"

class Quests::PlannerCheckTest < ActiveSupport::TestCase
  class FakeClient
    def initialize(&block)
      @block = block
    end

    def call(system:, user:, tool:)
      @block.call(JSON.parse(user))
    end
  end

  test "a valid response passes and leaves no data behind" do
    users_before = User.count
    tasks_before = Task.count
    client = FakeClient.new do |input|
      ids = input["eligible_tasks"].first(2).map { |t| t["task_id"] }
      { "plan_title" => "Kitchen Rescue", "intro" => "Hi", "encouragement" => "Go",
        "quests" => ids.map { |id| { "task_id" => id, "quest_title" => "Quest #{id}", "steps" => [ "Do it" ] } } }
    end

    result = Quests::PlannerCheck.call(client: client)
    assert result.ok, result.error
    assert_equal "ai", result.plan.source
    assert_equal users_before, User.count
    assert_equal tasks_before, Task.count
  end

  test "a response the app would reject is reported as a failure" do
    client = FakeClient.new { |_| { "plan_title" => "x", "intro" => "x", "encouragement" => "x", "quests" => [ { "task_id" => 0, "quest_title" => "x", "steps" => [] } ] } }
    result = Quests::PlannerCheck.call(client: client)
    assert_not result.ok
    assert_match(/Invalid/, result.error)
  end

  test "an API error is reported as a failure" do
    client = FakeClient.new { |_| raise Quests::ClaudeClient::Error, "boom" }
    result = Quests::PlannerCheck.call(client: client)
    assert_not result.ok
    assert_match(/boom/, result.error)
  end

  test "the rake task explains itself when no key is set" do
    Rails.application.load_tasks unless Rake::Task.task_defined?("nest_quest:check_planner")
    original = ENV.delete("ANTHROPIC_API_KEY")
    task = Rake::Task["nest_quest:check_planner"]
    task.reenable
    out, = capture_io { assert_raises(SystemExit) { task.invoke } }
    assert_match(/ANTHROPIC_API_KEY is not set/, out)
  ensure
    ENV["ANTHROPIC_API_KEY"] = original if original
  end
end
