module Api
  module V1
    class TasksController < BaseController
      before_action :set_task, only: %i[show update destroy]

      def index
        tasks = Task.includes(:project, :assigned_user).order(due_date: :asc)
        render json: tasks.as_json(include: {
          project: { only: %i[id name] },
          assigned_user: { only: %i[id name email] }
        })
      end

      def show
        render json: @task.as_json(include: {
          project: { only: %i[id name] },
          assigned_user: { only: %i[id name email] }
        })
      end

      def create
        task = Task.new(task_params)
        if task.save
          render json: task, status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: @task
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @task.destroy
        render json: { message: "Task deleted" }
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def task_params
        params.require(:task).permit(:title, :description, :due_date, :status, :project_id, :assigned_user_id)
      end
    end
  end
end
