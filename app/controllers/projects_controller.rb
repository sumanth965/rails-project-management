class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :authorize_project!, only: %i[show edit update destroy]

  def index
    @query = params[:q].to_s.strip

    @projects = if admin?
                  Project.includes(:owner, :members)
                else
                  Project.includes(:owner, :members)
                         .where(owner: current_user)
                         .or(Project.where(id: current_user.project_ids))
                end

    @projects = @projects.search(@query) if @query.present?
    @projects = @projects.order(deadline: :asc)
  end

  def show
    @task_query = params[:task_q].to_s.strip
    @task_status = params[:task_status].to_s
    @task_priority = params[:task_priority].to_s

    tasks_scope = @project.tasks.includes(:assigned_user)
    @tasks = tasks_scope.search(@task_query)
                       .for_status(@task_status)
                       .for_priority(@task_priority)
                       .order(:due_date)
  end

  def new
    @project = current_user.owned_projects.build
  end

  def create
    @project = current_user.owned_projects.build(project_params)

    if @project.save
      @project.project_memberships.find_or_create_by!(user: current_user) do |membership|
        membership.role = :manager
      end
      redirect_to @project, notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      @project.project_memberships.find_or_create_by!(user: current_user) do |membership|
        membership.role = :manager
      end
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_admin! unless @project.owner == current_user
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_project!
    return if admin?
    return if @project.owner == current_user
    return if @project.members.exists?(current_user.id)

    redirect_to projects_path, alert: "You are not authorized to view that project."
  end

  def project_params
    params.require(:project).permit(:name, :description, :deadline, :status, member_ids: [])
  end
end
