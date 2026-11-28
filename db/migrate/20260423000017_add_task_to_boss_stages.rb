class AddTaskToBossStages < ActiveRecord::Migration[8.0]
  def change
    add_reference :boss_stages, :task, foreign_key: { on_delete: :nullify }, null: true
  end
end
