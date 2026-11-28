class EvolveTodosIntoTasks < ActiveRecord::Migration[8.0]
  def up
    rename_table :todos, :tasks
    rename_column :tasks, :description, :title

    change_table :tasks do |t|
      t.text :notes
      t.string :room, null: false, default: "other"
      t.string :category, null: false, default: "other"
      t.integer :duration_minutes, null: false, default: 10
      t.string :effort, null: false, default: "small"
      t.string :priority, null: false, default: "normal"
      t.date :due_on
      t.string :recurrence_kind, null: false, default: "none"
      t.integer :recurrence_interval_days
      t.integer :recurrence_weekdays, array: true, null: false, default: []
      t.date :next_due_on
      t.string :status, null: false, default: "active"
      t.date :deferred_until
      t.datetime :completed_at
      t.string :monster_key
      t.string :fantasy_title
    end

    execute "UPDATE tasks SET completed_at = updated_at WHERE completed = TRUE"
    remove_column :tasks, :completed

    add_index :tasks, [ :user_id, :status ]

    create_table :completions do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :completed_at, null: false
      t.date :previous_next_due_on
      t.datetime :undone_at

      t.timestamps
    end
    add_index :completions, [ :user_id, :completed_at ]
  end

  def down
    drop_table :completions

    add_column :tasks, :completed, :boolean, null: false, default: false
    execute "UPDATE tasks SET completed = TRUE WHERE completed_at IS NOT NULL"
    remove_index :tasks, [ :user_id, :status ]

    remove_columns :tasks, :notes, :room, :category, :duration_minutes, :effort, :priority,
                   :due_on, :recurrence_kind, :recurrence_interval_days, :recurrence_weekdays,
                   :next_due_on, :status, :deferred_until, :completed_at, :monster_key, :fantasy_title

    rename_column :tasks, :title, :description
    rename_table :tasks, :todos
  end
end
