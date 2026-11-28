class AddRemindOnToTodos < ActiveRecord::Migration[8.0]
  def change
    add_column :todos, :remind_on, :date
  end
end
