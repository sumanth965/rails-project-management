class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.date :due_date, null: false
      t.integer :status, default: 0, null: false
      t.references :project, null: false, foreign_key: true
      t.references :assigned_user, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
