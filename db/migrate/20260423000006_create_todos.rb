class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :description, null: false
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :todos, [ :user_id, :created_at ]
  end
end
