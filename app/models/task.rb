class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assigned_user, class_name: "User", optional: true

  enum :status, { todo: 0, in_progress: 1, done: 2 }

  validates :title, :status, :due_date, presence: true

  def overdue?
    due_date.present? && due_date < Date.current && !done?
  end
end
