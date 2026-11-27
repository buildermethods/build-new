# frozen_string_literal: true

# Step-by-step setup. Two flows share the same screens:
#   setup (/welcome/*)  - first run only; ends by marking the user onboarded.
#   add   (/chores/*)   - afterwards, to add more suggested chores.
class OnboardingController < ApplicationController
  STEPS = {
    "setup" => %w[intro rooms chores frequency finish],
    "add" => %w[rooms chores frequency]
  }.freeze
  LABELS = { "intro" => "Welcome", "rooms" => "Rooms", "chores" => "Chores", "frequency" => "How often", "finish" => "Finish" }.freeze

  before_action :enforce_mode
  before_action :load_draft

  def intro
    render_step "onboarding/Intro"
  end

  def rooms
    render_step "onboarding/Rooms", props: {
      rooms: Game::Catalog.chore_rooms.map { |key, r| { key: key, label: r["label"], max_count: r["max_count"], always: !!r["always"] } },
      counts: @draft.rooms
    }
  end

  def save_rooms
    @draft.rooms = params[:rooms]&.to_unsafe_h || {}
    return redirect_back(fallback_location: step_path("rooms"), inertia: { errors: { rooms: "Pick at least one room." } }) unless @draft.selected_rooms?

    @draft.save!
    redirect_to step_path("chores")
  end

  def chores
    return redirect_to(step_path("rooms")) unless @draft.selected_rooms?

    added = added_chore_keys
    selected = @draft.chores.presence || (mode == "setup" ? @draft.default_chores : [])
    render_step "onboarding/Chores", props: {
      groups: @draft.rooms.map { |room_key, count| chore_group(room_key, count, added) },
      selected: selected - added.to_a,
      mode: mode
    }
  end

  def save_chores
    @draft.chores = params[:chores]
    return redirect_back(fallback_location: step_path("chores"), inertia: { errors: { chores: "Pick at least one chore." } }) if @draft.chores.empty?

    @draft.save!
    redirect_to step_path("frequency")
  end

  def frequency
    return redirect_to(step_path("rooms")) unless @draft.selected_rooms?
    return redirect_to(step_path("chores")) if @draft.chores.empty?

    render_step "onboarding/Frequency", props: {
      chores: @draft.chores.map { |key| frequency_row(key) },
      frequency_options: Game::Catalog.frequencies.map { |key, f| { key: key, label: f["label"] } },
      mode: mode
    }
  end

  def save_frequency
    @draft.frequencies = params[:frequencies]&.to_unsafe_h || {}
    @draft.save!
    return redirect_to(step_path("finish")) if mode == "setup"

    created = Onboarding::Builder.call(user: Current.user, draft: @draft)
    @draft.clear!
    redirect_to quests_path, notice: created.zero? ? "Those chores were already on your board." : "Added #{created} suggested #{'chore'.pluralize(created)}."
  end

  def finish
    return redirect_to(step_path("chores")) if @draft.chores.empty?

    render_step "onboarding/Finish", props: {
      summary: { rooms: @draft.rooms.values.sum, chores: @draft.chores.size },
      anchors: Onboarding::Complete::ANCHORS
    }
  end

  def complete
    Onboarding::Complete.call(user: Current.user, draft: @draft, display_name: params[:display_name],
                              anchor: params[:anchor], treat: params[:treat])
    redirect_to root_path(energy: "gentle"),
                notice: "Welcome! A fern now sits in your cottage, and you start with a little XP. Here is your first quest."
  end

  def skip
    Onboarding::Complete.call(user: Current.user, draft: Onboarding::Draft.new(Current.user.tap { |u| u.onboarding_draft = {} }))
    redirect_to root_path
  end

  private
    def mode
      params[:mode].presence_in(STEPS.keys) || "setup"
    end

    # Setup is for people who have not finished it; "add" is for those who have.
    def enforce_mode
      onboarded = Current.user.onboarded?
      redirect_to(root_path) if mode == "setup" && onboarded
      redirect_to(welcome_path) if mode == "add" && !onboarded
    end

    def load_draft
      @draft = Onboarding::Draft.new(Current.user)
    end

    def step_path(step)
      base = mode == "setup" ? "/welcome" : "/add-chores"
      step == "intro" ? base : "#{base}/#{step}"
    end

    def render_step(page, props: {})
      steps = STEPS.fetch(mode)
      current = action_name.sub(/\Asave_/, "").sub("complete", "finish")
      index = steps.index(current) || 0
      render inertia: page, props: props.merge(
        wizard: {
          mode: mode,
          steps: steps.map { |s| { key: s, label: LABELS.fetch(s), path: step_path(s) } },
          current: steps[index],
          back_path: index.positive? ? step_path(steps[index - 1]) : nil
        },
        draft: { display_name: Current.user.display_name, anchor: Current.user.anchor, treat: Current.user.treat }
      )
    end

    # "room.chore" keys the user already has a task for (any instance).
    def added_chore_keys
      Current.user.tasks.where.not(source_key: nil).pluck(:source_key).map do |sk|
        room, _instance, chore = sk.split(":")
        "#{room}.#{chore}"
      end.to_set
    end

    def chore_group(room_key, count, added)
      room = Game::Catalog.chore_rooms.fetch(room_key)
      {
        key: room_key, label: room["label"], count: count,
        chores: room["chores"].map do |c|
          full = "#{room_key}.#{c['key']}"
          { key: full, title: c["title"], minutes: c["minutes"], effort: c["effort"],
            frequency: Game::Catalog.frequency(c["frequency"])["label"], added: added.include?(full) }
        end
      }
    end

    def frequency_row(key)
      room_key, chore_key = key.split(".", 2)
      chore = Game::Catalog.chore(room_key, chore_key)
      room = Game::Catalog.chore_rooms.fetch(room_key)
      { key: key, title: chore["title"], room_key: room_key, room_label: room["label"],
        minutes: chore["minutes"], frequency: @draft.frequency_for(key) }
    end
end
