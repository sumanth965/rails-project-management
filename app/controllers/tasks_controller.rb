class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy move]
  before_action :authorize_project!

  def show; end

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to project_path(@project), notice: "Task created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to project_path(@project), notice: "Task updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to project_path(@project), notice: "Task deleted successfully."
  end

  def move
    if @task.update(status: params[:status])
      head :ok
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def authorize_project!
    return if admin?
    return if @project.owner == current_user
    return if @project.members.exists?(current_user.id)

    redirect_to projects_path, alert: "You are not authorized to access that task."
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :status, :priority, :assigned_user_id)
  end
end
