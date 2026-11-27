class CreateSanctuaryTables < ActiveRecord::Migration[8.0]
  def change
    create_table :owned_decorations do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :decoration_key, null: false

      t.timestamps
    end
    add_index :owned_decorations, [ :user_id, :decoration_key ], unique: true

    create_table :sanctuary_placements do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :slot, null: false
      t.string :decoration_key, null: false

      t.timestamps
    end
    add_index :sanctuary_placements, [ :user_id, :slot ], unique: true

    # Purchases are ledger rows with no completion; `reference` holds the
    # decoration key so each can be bought at most once.
    add_column :reward_transactions, :reference, :string
    add_index :reward_transactions, [ :user_id, :reference ], unique: true,
              where: "kind = 'purchase'", name: "index_reward_transactions_once_per_purchase"
  end
end
