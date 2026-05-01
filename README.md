# Rails Project Management

A lightweight project management app built with Rails 8. It supports team-based projects, task assignment, dashboard analytics, and a JSON API.

## Features
- Devise authentication (signup/signin/signout)
- Role-aware access (`user`, `admin`)
- Project ownership + team memberships (`member`, `manager`)
- Task CRUD with statuses (`todo`, `in_progress`, `done`) and priorities (`low`, `medium`, `high`)
- Dashboard with stats, Kanban-style task movement, and recent activity
- Secured API v1 with Bearer token authentication

## Setup
### Prerequisites
- Ruby (see `rails_version.txt`)
- Bundler
- SQLite

### Install
```bash
bundle install
bin/rails db:create db:migrate db:seed
```

### Run
```bash
bin/dev
```
App runs on `http://localhost:3000`.

## Auth & Roles
- All web pages require login (except Devise pages).
- `admin` can access all projects/tasks.
- Non-admin users can access projects they own or joined.

## API Authentication
Use Bearer token in `Authorization` header.

### Get current API token (logged-in web session)
```bash
curl -X GET http://localhost:3000/api_token -b cookie.txt
```

### Regenerate API token
```bash
curl -X POST http://localhost:3000/api_token/regenerate -b cookie.txt
```

### Example API call
```bash
curl -H "Authorization: Bearer <API_TOKEN>" http://localhost:3000/api/v1/projects
```

## Permission Matrix
| Role | View Project | Edit Project | Delete Project | Manage Any Task | Update Assigned Task |
|------|---------------|--------------|----------------|------------------|----------------------|
| Admin | Yes | Yes | Yes | Yes | Yes |
| Owner | Yes | Yes | Yes | Yes | Yes |
| Manager | Yes | Yes | No | Yes | Yes |
| Member | Yes | No | No | No | Yes |

## Tests & Checks
```bash
bin/rails test
bin/rubocop
bin/brakeman
```

## Troubleshooting
- If migrations fail, run: `bin/rails db:drop db:create db:migrate`.
- If auth appears broken, clear browser cookies and sign in again.
- If API returns 401, verify Bearer token and spacing in header.
