class CreateRoutinesAndOnboarding < ActiveRecord::Migration[8.0]
  def up
    create_table :routines do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :weekdays, array: true, null: false, default: [] # empty = every day

      t.timestamps
    end

    create_table :routine_steps do |t|
      t.references :routine, null: false, foreign_key: true
      t.references :task, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :routine_step_completions do |t|
      t.references :routine_step, null: false, foreign_key: true, index: false
      t.date :on_date, null: false

      t.timestamps
    end
    add_index :routine_step_completions, [ :routine_step_id, :on_date ], unique: true

    # Routine bonuses are ledger rows keyed "routine_id:date" so each routine
    # pays out at most once per day.
    add_index :reward_transactions, [ :user_id, :reference ], unique: true,
              where: "kind = 'routine_bonus'", name: "index_reward_transactions_once_per_routine_day"

    add_column :users, :display_name, :string
    add_column :users, :reduced_motion, :boolean, null: false, default: false
    add_column :users, :onboarded_at, :datetime

    # Everyone who exists today has already been using the app.
    execute "UPDATE users SET onboarded_at = NOW()"
  end

  def down
    remove_column :users, :onboarded_at
    remove_column :users, :reduced_motion
    remove_column :users, :display_name
    remove_index :reward_transactions, name: "index_reward_transactions_once_per_routine_day"
    drop_table :routine_step_completions
    drop_table :routine_steps
    drop_table :routines
  end
end
