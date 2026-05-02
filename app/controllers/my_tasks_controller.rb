class MyTasksController < ApplicationController
  def index
    @tasks = current_user.assigned_tasks.order(due_date: :asc)
    
    if params[:status].present?
      @tasks = @tasks.where(status: params[:status])
    end
    
    if params[:priority].present?
      @tasks = @tasks.where(priority: params[:priority])
    end
  end
end
