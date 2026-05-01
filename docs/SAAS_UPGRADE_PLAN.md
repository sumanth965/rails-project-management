# Jira-Style SaaS Upgrade Plan (Rails)

## 1) Current-State Analysis (what exists)
- Authentication is already implemented with Devise and `ApplicationController` enforces sign-in for non-Devise pages.
- Core domain models exist: `User`, `Project`, `Task`, and `ProjectMembership`.
- Role and access foundations exist (`User.role`, membership roles, and `ProjectAccess` concern).
- UI shell already has sidebar + top navbar and a dashboard pattern.
- API endpoints already exist under `/api/v1` for projects/tasks.

## 2) Gaps vs. production SaaS expectations
- **Authorization consistency:** some resource loading fetches by `Project.find` before authorization; should always scope by accessible projects.
- **Controller density:** filtering and board aggregation logic is in controllers; can move into query/service classes.
- **N+1/query pressure:** Kanban columns were repeatedly querying by status in the view.
- **Feature completeness:** comments, activity history/auditing, reminders, and true drag-and-drop board are not complete.
- **Pagination UX:** currently list pages are not fully paginated for larger datasets.
- **API maturity:** serializer/versioning/error payload standards should be normalized.
- **Ops readiness:** deployment checklists and environment-specific operational docs should be explicit.

## 3) Recommended Target Architecture
- `app/queries/*` for list/filter access patterns (`ProjectsQuery`, `TasksQuery`).
- `app/services/*` for state transitions and auditing (`Tasks::TransitionService`).
- `app/policies/*` (Pundit) or keep concern-based auth but centralize all checks.
- `app/presenters/*` for dashboard/kanban aggregation.
- `app/components/*` (ViewComponent optional) for reusable UI cards/badges/modals.

## 4) Data Model Roadmap (incremental)
1. Add `comments` table (`task_id`, `user_id`, `body`).
2. Add `activities` table (`actor_id`, `subject_type/id`, `action`, `changeset`, `project_id`, `task_id`).
3. Add `due_reminders` table and background jobs (`solid_queue`) for notification scheduling.
4. Add project-level settings table for defaults/workflows.

## 5) Flow Hardening
Desired flow (already mostly present):
`Login -> Dashboard -> Projects -> Tasks -> Task Details`

Improvements:
- Ensure every sidebar/topbar action maps cleanly to this flow.
- Add task detail breadcrumbs (`Dashboard / Project / Task`).
- Add post-create redirects with context (after creating task, optionally open task detail).

## 6) Backend Refactor Plan
- Move project/task filtering into query objects.
- Keep controllers thin: load resource, authorize, call query/service, render.
- Add more model constraints:
  - `Task`: validate `due_date >= project.created_at.to_date` (optional business rule).
  - `Project`: validate `deadline >= Date.current` for new projects if desired.
- Add DB indexes for high-volume paths:
  - `tasks(project_id, status, due_date)`
  - `project_memberships(project_id, user_id)` unique.

## 7) Jira-Level Feature Delivery Sequence
1. **Kanban Drag-and-Drop** using Stimulus + SortableJS + Turbo stream update endpoint.
2. **Comments** on task detail page with inline form.
3. **Activity timeline** on project/task pages.
4. **Assignment UX** with searchable assignee selector.
5. **Reminders** with scheduled jobs and in-app notifications.

## 8) UI/UX Upgrade Recommendations (Tailwind)
- Introduce Tailwind tokens for spacing/color/typography and remove ad-hoc inline styles progressively.
- Standardize layouts:
  - `DashboardLayout` with fixed sidebar + sticky topbar.
  - `ProjectLayout` with split view (board + details panel).
- Reusable partials/components:
  - `_stat_card`, `_status_badge`, `_priority_badge`, `_empty_state`, `_modal`.

## 9) API Future-Readiness
- Keep `/api/v1`, add consistent envelope:
  - `{ data: ..., meta: ..., errors: ... }`
- Add token expiration/rotation policy and request throttling.
- Add OpenAPI spec for React/Next.js consumers.

## 10) Production Readiness Checklist
- Secrets in environment variables only.
- Add healthcheck endpoint and uptime monitoring.
- Configure background jobs, queue adapters, and retry policies.
- Add CI checks: `rubocop`, `brakeman`, tests.
- Add error tracking (Sentry/Bugsnag) and structured logging.

## 11) Example refactor pattern
```ruby
# app/queries/tasks_query.rb
class TasksQuery
  def initialize(scope = Task.all)
    @scope = scope
  end

  def call(params = {})
    @scope
      .includes(:project, :assigned_user)
      .yield_self { |s| params[:q].present? ? s.search(params[:q]) : s }
      .yield_self { |s| params[:status].present? ? s.for_status(params[:status]) : s }
      .yield_self { |s| params[:priority].present? ? s.for_priority(params[:priority]) : s }
      .order(due_date: :asc)
  end
end
```

Use this as a next refactor to keep controllers concise and testable.
