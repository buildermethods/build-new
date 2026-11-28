class AddChoreCatalogueFields < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :onboarding_draft, :jsonb, null: false, default: {}
    add_column :users, :anchor, :string
    add_column :users, :treat, :string

    # source_key identifies a catalogue chore instance ("bedroom:2:floor") so
    # adding suggested chores later never duplicates one.
    add_column :tasks, :room_label, :string
    add_column :tasks, :source_key, :string
    add_index :tasks, [ :user_id, :source_key ], unique: true, where: "source_key IS NOT NULL"
  end
end
