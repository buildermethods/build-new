class CreateBossBattles < ActiveRecord::Migration[8.0]
  def change
    create_table :boss_battles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :monster_key, null: false
      t.string :status, null: false, default: "active"
      t.datetime :defeated_at

      t.timestamps
    end
    add_index :boss_battles, [ :user_id, :status ]

    create_table :boss_stages do |t|
      t.references :boss_battle, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false, default: 0
      t.integer :damage, null: false, default: 0
      t.datetime :completed_at

      t.timestamps
    end
  end
end
