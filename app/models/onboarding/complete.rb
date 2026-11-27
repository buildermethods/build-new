# frozen_string_literal: true

module Onboarding
  # Finishes first-run setup: builds tasks from the draft, gifts a first
  # decoration so the cottage isn't bare, stores the player's preferences and
  # marks them onboarded. Runs once; later calls are no-ops.
  class Complete
    GIFT = "fern_pot"
    ANCHORS = [ "after my morning coffee", "after the school run", "after lunch", "after dinner", "before bed" ].freeze

    def self.call(user:, draft:, display_name: nil, anchor: nil, treat: nil)
      return false if user.onboarded?

      User.transaction do
        Builder.call(user: user, draft: draft)
        user.owned_decorations.find_or_create_by!(decoration_key: GIFT)
        Sanctuary::Equip.call(user: user, key: GIFT)
        Game::AwardOneOff.call(user: user, kind: "welcome", reference: "welcome", xp: Game::Economy.welcome_xp)
        user.update!(
          display_name: display_name.to_s.squish.first(40).presence,
          anchor: ANCHORS.include?(anchor) ? anchor : nil,
          treat: treat.to_s.squish.first(60).presence,
          onboarded_at: Time.current,
          onboarding_draft: {}
        )
      end
      true
    end
  end
end
