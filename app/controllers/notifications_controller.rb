class NotificationsController < ApplicationController
  def index
    # Mock notifications for UI demonstration
    @notifications = [
      { id: 1, type: :task, message: "New task assigned: 'Update API Documentation'", time: "2 hours ago", unread: true },
      { id: 2, type: :project, message: "Project 'Skyline Redesign' was updated by Admin", time: "5 hours ago", unread: true },
      { id: 3, type: :comment, message: "Sarah commented on your task 'Fix Login Bug'", time: "Yesterday", unread: false },
      { id: 4, type: :alert, message: "Task 'Database Migration' is overdue", time: "2 days ago", unread: false },
      { id: 5, type: :task, message: "Task 'Client Review' marked as completed", time: "3 days ago", unread: false }
    ]
  end
end
