class TeamsController < ApplicationController
  def index
    @users = User.all.order(:name)
  end
end
