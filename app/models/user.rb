class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { user: 0, admin: 1 }

  has_many :owned_projects, class_name: "Project", foreign_key: "owner_id", dependent: :nullify
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :assigned_tasks, class_name: "Task", foreign_key: "assigned_user_id", dependent: :nullify

  validates :name, presence: true
end
