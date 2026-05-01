require "securerandom"

class AddCodeToProjects < ActiveRecord::Migration[8.1]
  def up
    add_column :projects, :code, :string
    add_index :projects, :code, unique: true

    Project.reset_column_information
    Project.find_each do |project|
      project.update!(code: generate_code(project.name))
    end
  end

  def down
    remove_index :projects, :code
    remove_column :projects, :code
  end

  private

  def generate_code(name)
    base = name.to_s.parameterize.truncate(20, omission: "")
    slug = base.presence || "project"
    "#{slug}-#{SecureRandom.alphanumeric(8).downcase}"
  end
end
