class TasksController < ApplicationController
  include ProjectAccess

  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy move]
  before_action :authorize_view_project!
  before_action :authorize_manage_project!, only: %i[new create edit destroy]
  before_action :authorize_manage_task!, only: %i[update move]

  def show; end

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to project_path(@project), notice: 'Task created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to project_path(@project), notice: 'Task updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to project_path(@project), notice: 'Task deleted successfully.'
  end

  def move
    if @task.update(status: params[:status])
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: "Task moved to #{params[:status].humanize}." }
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: 'Error moving task.' }
        format.json { render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def authorize_view_project!
    return if can_view_project?(current_user, @project)

    redirect_to projects_path, alert: 'You are not authorized to access that task.'
  end

  def authorize_manage_project!
    return if can_manage_project?(current_user, @project)

    redirect_to project_path(@project), alert: 'You do not have permission for task management.'
  end

  def authorize_manage_task!
    return if can_manage_task?(current_user, @task)

    redirect_to project_path(@project), alert: 'You do not have permission to modify this task.'
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :status, :priority, :assigned_user_id)
  end
end
