require 'test_helper'

class ApiSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(name: 'Owner', email: 'owner@example.com', password: 'Password1!')
    @member = User.create!(name: 'Member', email: 'member@example.com', password: 'Password1!')
    @outsider = User.create!(name: 'Outsider', email: 'outsider@example.com', password: 'Password1!')
    @project = Project.create!(name: 'Alpha', description: 'A', deadline: Date.today + 1, status: :active, owner: @owner)
    ProjectMembership.create!(project: @project, user: @member, role: :member)
    @task = Task.create!(project: @project, title: 'Task 1', due_date: Date.today + 1, status: :todo, priority: :high, assigned_user: @member)
  end

  test 'requires bearer token' do
    get '/api/v1/projects'
    assert_response :unauthorized
  end

  test 'outsider cannot view private project' do
    @outsider.regenerate_api_token
    get "/api/v1/projects/#{@project.id}", headers: { 'Authorization' => "Bearer #{@outsider.api_token}" }
    assert_response :forbidden
  end

  test 'member can update assigned task' do
    @member.regenerate_api_token
    patch "/api/v1/tasks/#{@task.id}", params: { task: { status: 'done' } }, headers: { 'Authorization' => "Bearer #{@member.api_token}" }
    assert_response :ok
    assert_equal 'done', @task.reload.status
  end
end
