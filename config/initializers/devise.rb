Devise.setup do |config|
  config.mailer_sender = "no-reply@projectmanager.dev"
  config.secret_key = Rails.application.credentials.secret_key_base if Rails.application.credentials.secret_key_base
  config.parent_controller = "ApplicationController"
  require "devise/orm/active_record"
end
