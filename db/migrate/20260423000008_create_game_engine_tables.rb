class CreateGameEngineTables < ActiveRecord::Migration[8.0]
  def change
    create_table :player_progresses do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :xp, null: false, default: 0
      t.integer :coins, null: false, default: 0

      t.timestamps
    end

    create_table :reward_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :completion, foreign_key: true
      t.string :kind, null: false
      t.integer :xp_delta, null: false, default: 0
      t.integer :coin_delta, null: false, default: 0

      t.timestamps
    end

    # Exactly-once: at most one reward (and one reversal) per completion.
    add_index :reward_transactions, [ :completion_id, :kind ], unique: true,
              where: "completion_id IS NOT NULL", name: "index_reward_transactions_once_per_completion"
  end
end
