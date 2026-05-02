class ReportsController < ApplicationController
  def index
    @projects = Project.all
    @total_tasks = Task.count
    @completed_tasks = Task.done.count
    @overdue_tasks = Task.where('due_date < ? AND status != ?', Date.current, Task.statuses[:done]).count
    
    # Simple data for a "chart" representation in view
    @project_stats = @projects.map do |project|
      {
        name: project.name,
        total: project.tasks.count,
        done: project.tasks.done.count,
        progress: project.tasks.any? ? (project.tasks.done.count.to_f / project.tasks.count * 100).round : 0
      }
    end
  end
end
