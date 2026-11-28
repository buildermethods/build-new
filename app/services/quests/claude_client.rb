# frozen_string_literal: true

require "net/http"
require "json"

module Quests
  # Thin server-side client for the Claude Messages API. It forces a single
  # tool call so the response is structured JSON matching a schema we supply.
  # The API key only ever lives in the environment, never in client code.
  class ClaudeClient
    class Error < StandardError; end

    ENDPOINT = URI("https://api.anthropic.com/v1/messages")
    MODEL = "claude-sonnet-5-5"
    API_VERSION = "2023-06-01"

    def self.configured?
      ENV["ANTHROPIC_API_KEY"].present?
    end

    def initialize(api_key: ENV["ANTHROPIC_API_KEY"], transport: nil)
      @api_key = api_key
      @transport = transport || method(:http_transport)
    end

    # Returns the tool input (a Hash). Raises Error on any failure.
    def call(system:, user:, tool:)
      raise Error, "ANTHROPIC_API_KEY is not set" if @api_key.blank?

      body = {
        model: MODEL,
        max_tokens: 1024,
        system: system,
        messages: [ { role: "user", content: user } ],
        tools: [ tool ],
        tool_choice: { type: "tool", name: tool.fetch(:name) }
      }
      headers = { "content-type" => "application/json", "x-api-key" => @api_key, "anthropic-version" => API_VERSION }

      status, text = @transport.call(JSON.generate(body), headers)
      raise Error, "Claude API returned #{status}" unless status == 200

      block = Array(JSON.parse(text)["content"]).find { |b| b["type"] == "tool_use" }
      raise Error, "Claude response had no tool call" unless block && block["input"].is_a?(Hash)

      block["input"]
    rescue JSON::ParserError => e
      raise Error, "Claude response was not JSON: #{e.message}"
    end

    private
      def http_transport(body, headers)
        http = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
        http.use_ssl = true
        http.open_timeout = 3
        http.read_timeout = 12
        response = http.post(ENDPOINT.path, body, headers)
        [ response.code.to_i, response.body ]
      rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        raise Error, "Claude API unreachable: #{e.class}"
      end
  end
end
