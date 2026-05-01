admin = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.name = "Admin User"
  user.password = "password"
  user.password_confirmation = "password"
  user.role = :admin
end

user = User.find_or_create_by!(email: "user@example.com") do |account|
  account.name = "Jane Doe"
  account.password = "password"
  account.password_confirmation = "password"
  account.role = :user
end

project = Project.find_or_create_by!(name: "Launch Website") do |project_record|
  project_record.description = "Build the public website, connect the team, and track progress using tasks."
  project_record.deadline = 2.weeks.from_now.to_date
  project_record.status = :active
  project_record.owner = admin
end

project.members << user unless project.members.include?(user)
project.members << admin unless project.members.include?(admin)

Task.find_or_create_by!(title: "Design landing page", project: project) do |task|
  task.description = "Create mockups for the landing page and review with the product team."
  task.due_date = 5.days.from_now.to_date
  task.status = :in_progress
  task.assigned_user = user
end

Task.find_or_create_by!(title: "Set up authentication", project: project) do |task|
  task.description = "Add Devise for authentication and role-based admin access."
  task.due_date = 3.days.from_now.to_date
  task.status = :todo
  task.assigned_user = admin
end

puts "Seeded admin: #{admin.email}, user: #{user.email}, project: #{project.name}"
