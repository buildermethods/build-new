class AddCottageRooms < ActiveRecord::Migration[8.0]
  # Anonymous stand-in so this migration does not depend on app model code.
  class ProgressRow < ActiveRecord::Base
    self.table_name = "player_progresses"
  end

  def up
    add_column :sanctuary_placements, :room, :string, null: false, default: "living_room"
    remove_index :sanctuary_placements, [ :user_id, :slot ]
    add_index :sanctuary_placements, [ :user_id, :room, :slot ], unique: true

    # Rooms stay unlocked once reached, even if undoing a quest later lowers
    # the level, so remember the highest level ever reached.
    add_column :player_progresses, :peak_level, :integer, null: false, default: 1
    base = 100
    ProgressRow.reset_column_information
    ProgressRow.find_each do |row|
      level = 1
      level += 1 while row.xp >= base * (level + 1) * level / 2
      row.update_columns(peak_level: level)
    end
  end

  def down
    remove_column :player_progresses, :peak_level
    remove_index :sanctuary_placements, [ :user_id, :room, :slot ]
    execute "DELETE FROM sanctuary_placements WHERE room <> 'living_room'"
    add_index :sanctuary_placements, [ :user_id, :slot ], unique: true
    remove_column :sanctuary_placements, :room
  end
end
