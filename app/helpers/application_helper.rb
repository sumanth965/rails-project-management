module ApplicationHelper
  def bootstrap_flash_class(type)
    case type.to_sym
    when :notice then "success"
    when :alert then "danger"
    when :error then "danger"
    else "info"
    end
  end

  def status_badge(status)
    colors = case status.to_s
             when "planned", "todo" then "bg-surface-container-high text-on-surface-variant border-outline-variant"
             when "active", "in_progress" then "bg-secondary-container text-on-secondary-container border-secondary"
             when "completed", "done" then "bg-tertiary-fixed text-on-tertiary border-tertiary"
             when "overdue" then "bg-error-container text-on-error-container border-error"
             else "bg-surface-container-low text-on-surface-variant border-outline-variant"
             end

    content_tag(:span, status.to_s.humanize, class: "inline-flex items-center px-3 py-1 rounded-full text-xs font-bold border #{colors} uppercase tracking-wider")
  end
end
