module Api
  module V1
    class TasksController < BaseController
      before_action :set_task, only: %i[show update destroy]

      def index
        page, per_page = pagination_params
        scope = Task.includes(:project, :assigned_user)
                    .where(project_id: accessible_projects_for(current_api_user).select(:id))
                    .order(due_date: :asc)
        tasks = scope.offset((page - 1) * per_page).limit(per_page)
        render_data(tasks.as_json(include: {
          project: { only: %i[id name] },
          assigned_user: { only: %i[id name email] }
        }))
      end

      def show
        return render_error(['Forbidden'], :forbidden) unless can_view_project?(current_api_user, @task.project)
        render_data(@task.as_json(include: {
          project: { only: %i[id name] },
          assigned_user: { only: %i[id name email] }
        }))
      end

      def create
        task = Task.new(task_params)
        return render_error(['Forbidden'], :forbidden) unless can_manage_project?(current_api_user, task.project)
        if task.save
          render_data(task, status: :created)
        else
          render_error(task.errors.full_messages, :unprocessable_entity)
        end
      end

      def update
        return render_error(['Forbidden'], :forbidden) unless can_manage_task?(current_api_user, @task)
        if @task.update(task_params)
          render_data(@task)
        else
          render_error(@task.errors.full_messages, :unprocessable_entity)
        end
      end

      def destroy
        return render_error(['Forbidden'], :forbidden) unless can_manage_project?(current_api_user, @task.project)
        @task.destroy
        render_data({ message: 'Task deleted' })
      end

      private

      def set_task
        @task = Task.find_by(id: params[:id])
        render_error(['Not found'], :not_found) unless @task
      end

      def task_params
        params.require(:task).permit(:title, :description, :due_date, :status, :priority, :project_id, :assigned_user_id)
      end
    end
  end
end
