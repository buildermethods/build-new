# frozen_string_literal: true

module Habits
  # Warm, context-aware copy. Picked deterministically (by record id), not by
  # chance, so there is no "variable reward" slot-machine effect.
  module Messages
    QUIPS = {
      "laundry_troll" => [ "The Laundry Troll drops a sock and flees!", "Mountains of washing, conquered one load at a time." ],
      "dust_bunny_horde" => [ "The Dust Bunny Horde scatters, squeaking!", "Fluff defeated. The air feels lighter." ],
      "counter_goblins" => [ "The Counter Goblins scatter! The kitchen thanks you.", "Crumbs vanquished. Clear surfaces feel good." ],
      "bathroom_slime" => [ "The Bathroom Slime pops into bubbles!", "Sparkling sinks and a happy slime-free zone." ],
      "doom_pile_dragon" => [ "The Doom Pile Dragon curls up and snoozes.", "One pile smaller. The dragon's hoard shrinks." ],
      "toy_swarm" => [ "The Toy Swarm marches back to its box.", "Every toy home. The floor is yours again." ],
      "backpack_bandits" => [ "The Backpack Bandits return the loot. Tomorrow is ready.", "Bags packed, bandits outwitted." ],
      "wardrobe_wraith" => [ "The Wardrobe Wraith fades into the folds.", "A calmer wardrobe, a calmer you." ]
    }.freeze

    module_function

    def victory(task:, completion:, first:, leveled_up:)
      return "Your very first quest! Your cottage already feels cosier." if first
      return "Level up! Every quest like this is building a calmer home." if leveled_up

      pool = QUIPS.fetch(task.monster_key_or_default, QUIPS["dust_bunny_horde"])
      pool[completion.id % pool.size]
    end

    def identity(user, week)
      from = week.week_start
      range = user.zone.local(from.year, from.month, from.day).beginning_of_day...(user.zone.local(from.year, from.month, from.day).beginning_of_day + 7.days)
      rooms = user.completions.active.where(completed_at: range).joins(:task).group("tasks.room").count
      rooms.delete("other")
      room, count = rooms.max_by { |_, c| c }
      return "You've kept the #{room.tr('_', ' ')} calm #{count} #{count == 1 ? 'time' : 'times'} this week." if room && count >= 2

      total = week.active_dates.size
      return "#{total} small #{total == 1 ? 'win' : 'wins'} this week. That's how calm homes get built." if total.positive?

      "Every small win builds a calmer home."
    end
  end
end
