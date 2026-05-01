class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :admin?

  def admin?
    current_user&.admin?
  end

  def authorize_admin!
    return if admin?

    redirect_to root_path, alert: "Access denied."
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name])
  end
end
