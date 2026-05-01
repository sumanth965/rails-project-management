module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: %i[show update destroy]

      def index
        page, per_page = pagination_params
        scope = accessible_projects_for(current_api_user).includes(:owner, :members, :tasks).order(deadline: :asc)
        projects = scope.offset((page - 1) * per_page).limit(per_page)
        render_data(projects.as_json(include: {
          owner: { only: %i[id name email] },
          members: { only: %i[id name email] },
          tasks: { only: %i[id title status due_date assigned_user_id priority] }
        }))
      end

      def show
        return render_error(['Forbidden'], :forbidden) unless can_view_project?(current_api_user, @project)
        render_data(@project.as_json(include: {
          owner: { only: %i[id name email] },
          members: { only: %i[id name email] },
          tasks: { only: %i[id title status due_date assigned_user_id priority] }
        }))
      end

      def create
        project = current_api_user.owned_projects.build(project_params.except(:owner_id))
        if project.save
          project.project_memberships.find_or_create_by!(user: current_api_user) { |m| m.role = :manager }
          render_data(project, status: :created)
        else
          render_error(project.errors.full_messages, :unprocessable_entity)
        end
      end

      def update
        return render_error(['Forbidden'], :forbidden) unless can_manage_project?(current_api_user, @project)
        if @project.update(project_params.except(:owner_id))
          render_data(@project)
        else
          render_error(@project.errors.full_messages, :unprocessable_entity)
        end
      end

      def destroy
        return render_error(['Forbidden'], :forbidden) unless current_api_user.admin? || @project.owner == current_api_user
        @project.destroy
        render_data({ message: 'Project deleted' })
      end

      private

      def set_project
        @project = Project.find_by(id: params[:id])
        return render_error(['Not found'], :not_found) unless @project
      end

      def project_params
        params.require(:project).permit(:name, :description, :deadline, :status, :owner_id)
      end
    end
  end
end
