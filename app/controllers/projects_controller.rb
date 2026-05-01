class ProjectsController < ApplicationController
  include ProjectAccess

  before_action :set_project, only: %i[show edit update destroy]
  before_action :authorize_view_project!, only: %i[show]
  before_action :authorize_manage_project!, only: %i[edit update]

  def index
    @query = params[:q].to_s.strip
    @projects = accessible_projects_for(current_user).includes(:owner, :members)
    @projects = @projects.search(@query) if @query.present?
    @projects = @projects.order(deadline: :asc)
  end

  def show
    @task_query = params[:task_q].to_s.strip
    @task_status = params[:task_status].to_s
    @task_priority = params[:task_priority].to_s

    tasks_scope = @project.tasks.includes(:assigned_user)
    @tasks = tasks_scope.search(@task_query).for_status(@task_status).for_priority(@task_priority).order(:due_date)

    @kanban_tasks_by_status = @project.tasks.includes(:assigned_user).order(due_date: :asc).group_by(&:status)
    @task_counts_by_status = @project.tasks.group(:status).count
  end

  def new
    @project = current_user.owned_projects.build
  end

  def create
    @project = current_user.owned_projects.build(project_params)

    if @project.save
      @project.project_memberships.find_or_create_by!(user: current_user) { |membership| membership.role = :manager }
      redirect_to @project, notice: 'Project created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return redirect_to projects_path, alert: 'Only project owners or admins can delete projects.' unless current_user.admin? || @project.owner == current_user

    @project.destroy
    redirect_to projects_path, notice: 'Project deleted.'
  end

  private

  def set_project
    @project = accessible_projects_for(current_user).find(params[:id])
  end

  def authorize_view_project!
    return if can_view_project?(current_user, @project)

    redirect_to projects_path, alert: 'You are not authorized to view that project.'
  end

  def authorize_manage_project!
    return if can_manage_project?(current_user, @project)

    redirect_to projects_path, alert: 'You are not authorized to modify that project.'
  end

  def project_params
    params.require(:project).permit(:name, :description, :deadline, :status, member_ids: [])
  end
end
