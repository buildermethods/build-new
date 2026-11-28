class CreateQuickTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :title, null: false
      t.datetime :completed_at

      t.timestamps
    end
    add_index :todos, [ :user_id, :completed_at ]

    # Exactly-once guard for the one-off rewards added in this batch:
    # to-dos ("todo:ID"), boss stages and defeats, and challenge claims.
    add_index :reward_transactions, [ :user_id, :reference ], unique: true,
              where: "kind IN ('todo', 'boss_stage', 'boss_defeat', 'challenge')",
              name: "index_reward_transactions_once_per_engagement_reward"
  end
end
