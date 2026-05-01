class ApiTokensController < ApplicationController
  def show
    current_user.regenerate_api_token if current_user.api_token.blank?
    render json: { data: { api_token: current_user.api_token } }
  end

  def regenerate
    current_user.regenerate_api_token
    render json: { data: { api_token: current_user.api_token } }
  end
end
