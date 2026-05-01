class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assigned_user, class_name: "User", optional: true

  enum :status, { todo: 0, in_progress: 1, done: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }, default: :medium

  validates :title, :status, :due_date, :priority, presence: true
  validates :title, length: { maximum: 120 }
  validates :description, length: { maximum: 2000 }, allow_blank: true

  scope :for_status, ->(status) { status.present? ? where(status:) : all }
  scope :for_priority, ->(priority) { priority.present? ? where(priority:) : all }
  scope :search, lambda { |term|
    return all unless term.present?

    where("LOWER(tasks.title) LIKE :term OR LOWER(tasks.description) LIKE :term", term: "%#{term.downcase}%")
  }

  def overdue?
    due_date.present? && due_date < Date.current && !done?
  end
end
