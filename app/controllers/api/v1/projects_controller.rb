module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: %i[show update destroy]

      def index
        projects = Project.includes(:owner, :members, :tasks).order(deadline: :asc)
        render json: projects.as_json(include: {
          owner: { only: %i[id name email] },
          members: { only: %i[id name email] },
          tasks: { only: %i[id title status due_date assigned_user_id] }
        })
      end

      def show
        render json: @project.as_json(include: {
          owner: { only: %i[id name email] },
          members: { only: %i[id name email] },
          tasks: { only: %i[id title status due_date assigned_user_id] }
        })
      end

      def create
        project = Project.new(project_params)
        if project.save
          render json: project, status: :created
        else
          render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @project.update(project_params)
          render json: @project
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @project.destroy
        render json: { message: "Project deleted" }
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.require(:project).permit(:name, :description, :deadline, :status, :owner_id)
      end
    end
  end
end
