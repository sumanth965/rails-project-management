require 'test_helper'

class TaskStatusTest < ActiveSupport::TestCase
  test 'done is a valid status' do
    task = Task.new(title: 'x', due_date: Date.today + 1, status: :done, priority: :medium, project: Project.new(name: 'P', deadline: Date.today + 2, status: :active, owner: User.new(name: 'u', email: 'u@test.com', password: 'Password1!')))
    assert task.valid?
  end
end
