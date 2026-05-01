module Api
  module V1
    class BaseController < ActionController::API
      include ProjectAccess

      before_action :set_default_format
      before_action :authenticate_api_user!

      attr_reader :current_api_user

      private

      def set_default_format
        request.format = :json
      end

      def authenticate_api_user!
        token = request.headers['Authorization'].to_s.remove('Bearer ').strip
        @current_api_user = User.find_by(api_token: token)
        render_error(['Unauthorized'], :unauthorized) unless @current_api_user
      end

      def render_data(payload, status: :ok)
        render json: { data: payload }, status:
      end

      def render_error(errors, status)
        render json: { errors: Array(errors) }, status:
      end

      def pagination_params
        page = params.fetch(:page, 1).to_i
        per_page = params.fetch(:per_page, 25).to_i
        page = 1 if page < 1
        per_page = 25 if per_page < 1
        per_page = 100 if per_page > 100
        [page, per_page]
      end
    end
  end
end
