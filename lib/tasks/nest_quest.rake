namespace :nest_quest do
  desc "Make one real Claude call with a sample household and report whether the plan validates (needs ANTHROPIC_API_KEY)"
  task check_planner: :environment do
    unless Quests::ClaudeClient.configured?
      puts "ANTHROPIC_API_KEY is not set. Run:  ANTHROPIC_API_KEY=sk-... bin/rails nest_quest:check_planner"
      exit 1
    end

    puts "Calling #{Quests::ClaudeClient::MODEL} ..."
    result = Quests::PlannerCheck.call(client: Quests::ClaudeClient.new)

    if result.ok
      plan = result.plan
      puts "OK: the response parsed and passed every validation rule (source: #{plan.source})."
      puts "Plan: #{plan.title} (#{plan.total_minutes} of #{plan.minutes} minutes)"
      plan.quests.each { |q| puts "  - #{q[:quest_title]}: #{q[:real_task]} (#{q[:estimated_minutes]} min)" }
      puts "Nothing was saved; the sample household was rolled back."
    else
      puts "FAILED: #{result.error}"
      puts "The app would fall back to the rules-based plan in this case."
      exit 1
    end
  end
end
