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
    tone = case status.to_s
    when "planned", "todo" then "secondary"
    when "active", "in_progress" then "warning"
    when "completed", "done" then "success"
    else "light"
    end

    content_tag(:span, status.to_s.humanize, class: "badge bg-#{tone}")
  end
end
