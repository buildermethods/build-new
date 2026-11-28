class CreateHabitTables < ActiveRecord::Migration[8.0]
  def change
    # "When will you do it?" - one chosen task and anchor per user per day.
    create_table :daily_intentions do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :task, null: false, foreign_key: { on_delete: :cascade }
      t.date :on_date, null: false
      t.string :anchor

      t.timestamps
    end
    add_index :daily_intentions, [ :user_id, :on_date ], unique: true

    create_table :user_achievements do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :key, null: false
      t.datetime :earned_at, null: false

      t.timestamps
    end
    add_index :user_achievements, [ :user_id, :key ], unique: true

    # One-off XP (starting a task, the welcome bonus) is exactly-once per
    # reference: "task_id:date" for starts, "welcome" for the bonus.
    add_index :reward_transactions, [ :user_id, :reference ], unique: true,
              where: "kind IN ('start', 'welcome')", name: "index_reward_transactions_once_per_one_off"
  end
end
