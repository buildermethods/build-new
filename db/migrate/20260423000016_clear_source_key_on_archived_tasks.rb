class ClearSourceKeyOnArchivedTasks < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE tasks SET source_key = NULL WHERE status = 'archived'"
  end

  def down
    # Archived tasks no longer carry a catalogue key; nothing to restore.
  end
end
