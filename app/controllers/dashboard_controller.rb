class DashboardController < ApplicationController
  def show
    @projects = accessible_projects
                .includes(:owner, :tasks)
                .order(deadline: :asc)
                .limit(6)

    @recent_tasks = Task.includes(:project, :assigned_user)
                        .joins(:project)
                        .where(projects: { id: accessible_projects.select(:id) })
                        .order(updated_at: :desc)
                        .limit(8)
  end

  private

  def accessible_projects
    return Project.all if admin?

    Project.where(owner: current_user)
           .or(Project.where(id: current_user.project_ids))
           .distinct
  end
end
