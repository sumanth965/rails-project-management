module ProjectAccess
  extend ActiveSupport::Concern

  private

  def accessible_projects_for(user)
    return Project.all if user&.admin?

    Project.where(owner: user)
           .or(Project.where(id: user.project_ids))
           .distinct
  end

  def can_manage_project?(user, project)
    return true if user&.admin? || project.owner_id == user&.id

    project.project_memberships.where(user_id: user.id, role: :manager).exists?
  end

  def can_view_project?(user, project)
    return true if user&.admin? || project.owner_id == user&.id

    project.members.exists?(user.id)
  end

  def can_manage_task?(user, task)
    return true if can_manage_project?(user, task.project)

    task.assigned_user_id == user&.id
  end
end
