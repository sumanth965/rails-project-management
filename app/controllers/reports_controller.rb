class ReportsController < ApplicationController
  def index
    @projects = Project.all
    @total_tasks = Task.count
    @completed_tasks = Task.done.count
    @in_progress_tasks = Task.in_progress.count
    @todo_tasks = Task.todo.count
    @overdue_tasks = Task.where('due_date < ? AND status != ?', Date.current, Task.statuses[:done]).count
    
    # Project statistics for charts and table
    @project_stats = @projects.map do |project|
      total = project.tasks.count
      done = project.tasks.done.count
      {
        name: project.name,
        total: total,
        done: done,
        progress: total > 0 ? ((done.to_f / total) * 100).round : 0
      }
    end
  end
end
