class Project < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :tasks, dependent: :destroy

  enum :status, { planned: 0, active: 1, completed: 2 }

  before_validation :generate_code, on: :create

  validates :name, :deadline, :status, :code, presence: true
  validates :code, uniqueness: true

  scope :search, lambda { |term|
    return all unless term.present?

    where(
      "LOWER(name) LIKE :term OR LOWER(description) LIKE :term OR LOWER(code) LIKE :term",
      term: "%#{term.downcase}%"
    )
  }

  def member_role(user)
    project_memberships.find_by(user_id: user.id)&.role
  end

  def completed_task_percentage
    return 0 if tasks.count.zero?
    (tasks.done.count * 100.0 / tasks.count).round
  end

  def progress_percentage
    completed_task_percentage
  end

  def overdue_tasks
    tasks.where("due_date < ? AND status != ?", Date.current, Task.statuses[:done])
  end

  private

  def generate_code
    return if code.present?

    base = name.to_s.parameterize.truncate(20, omission: "")
    slug = base.presence || "project"
    self.code = "#{slug}-#{SecureRandom.alphanumeric(8).downcase}"
  end
end
