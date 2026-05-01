class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum :role, { member: 0, manager: 1 }

  validates :user_id, uniqueness: { scope: :project_id }
end
