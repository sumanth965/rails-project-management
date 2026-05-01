class DashboardController < ApplicationController
  include ProjectAccess
  def show
    @projects = accessible_projects
                .includes(:owner, :tasks)
                .order(deadline: :asc)
                .limit(6)

    @accessible_project_ids = accessible_projects.select(:id)

    @recent_tasks = Task.includes(:project, :assigned_user)
                        .where(project_id: @accessible_project_ids)
                        .order(updated_at: :desc)
                        .limit(8)

    @tasks_due_today = Task.where(project_id: @accessible_project_ids)
                           .where(due_date: Date.today)
                           .count

    @completed_tasks_count = Task.where(project_id: @accessible_project_ids)
                                 .where(status: :done)
                                 .count

    @team_members_count = User.joins(:project_memberships)
                              .where(project_memberships: { project_id: @accessible_project_ids })
                              .distinct
                              .count

    @kanban_tasks = Task.includes(:project, :assigned_user)
                        .where(project_id: @accessible_project_ids)
                        .order(priority: :desc, due_date: :asc)
                        .limit(20)
                        .group_by(&:status)
  end

  private

  def accessible_projects
    return Project.all if admin?

    Project.where(owner: current_user)
           .or(Project.where(id: current_user.project_ids))
           .distinct
  end
end
