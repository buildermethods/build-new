class CreateHouseholdMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :household_members do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :household_members, [ :user_id, :position ]

    add_reference :tasks, :assignee, foreign_key: { to_table: :household_members, on_delete: :nullify }, null: true
    add_column :tasks, :rotate, :boolean, null: false, default: false
    add_column :completions, :previous_assignee_id, :bigint
  end
end
