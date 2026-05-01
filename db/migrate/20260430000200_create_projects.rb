class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.date :deadline, null: false
      t.integer :status, default: 0, null: false
      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
