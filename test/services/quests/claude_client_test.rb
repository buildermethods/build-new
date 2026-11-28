require "test_helper"

class Quests::ClaudeClientTest < ActiveSupport::TestCase
  TOOL = { name: "submit_plan", description: "x", input_schema: { type: "object" } }.freeze

  def client(status: 200, body: nil, key: "sk-test")
    body ||= JSON.generate(content: [ { type: "tool_use", name: "submit_plan", input: { "plan_title" => "Hi" } } ])
    @requests = []
    transport = ->(req_body, headers) { @requests << [ JSON.parse(req_body), headers ]; [ status, body ] }
    Quests::ClaudeClient.new(api_key: key, transport: transport)
  end

  test "returns the forced tool input" do
    assert_equal({ "plan_title" => "Hi" }, client.call(system: "s", user: "u", tool: TOOL))
  end

  test "sends the model, forced tool choice and key header" do
    client.call(system: "s", user: "u", tool: TOOL)
    body, headers = @requests.first
    assert_equal "claude-sonnet-5-5", body["model"]
    assert_equal({ "type" => "tool", "name" => "submit_plan" }, body["tool_choice"])
    assert_equal "sk-test", headers["x-api-key"]
  end

  test "raises on a non-200 response" do
    assert_raises(Quests::ClaudeClient::Error) { client(status: 500, body: "{}").call(system: "s", user: "u", tool: TOOL) }
  end

  test "raises when there is no tool call" do
    body = JSON.generate(content: [ { type: "text", text: "hello" } ])
    assert_raises(Quests::ClaudeClient::Error) { client(body: body).call(system: "s", user: "u", tool: TOOL) }
  end

  test "raises on malformed JSON" do
    assert_raises(Quests::ClaudeClient::Error) { client(body: "nope").call(system: "s", user: "u", tool: TOOL) }
  end

  test "raises without an API key" do
    assert_raises(Quests::ClaudeClient::Error) { client(key: nil).call(system: "s", user: "u", tool: TOOL) }
  end
end
