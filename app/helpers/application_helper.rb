module ApplicationHelper
  def bootstrap_flash_class(type)
    case type.to_sym
    when :notice then "success"
    when :alert  then "danger"
    when :error  then "danger"
    else "info"
    end
  end

  def status_badge(status)
    css = case status.to_s
          when "planned"      then "badge badge-planned"
          when "todo"         then "badge badge-todo"
          when "active"       then "badge badge-active"
          when "in_progress"  then "badge badge-in-progress"
          when "completed"    then "badge badge-completed"
          when "done"         then "badge badge-done"
          when "overdue"      then "badge badge-overdue"
          else "badge badge-todo"
          end
    content_tag(:span, status.to_s.humanize, class: css)
  end

  def priority_badge(priority)
    css = case priority.to_s
          when "low"      then "badge badge-low"
          when "medium"   then "badge badge-medium"
          when "high"     then "badge badge-high"
          when "critical" then "badge badge-critical"
          else "badge badge-low"
          end
    content_tag(:span, priority.to_s.humanize, class: css)
  end

  def initials(name)
    name.to_s.split.first(2).map { |w| w[0].upcase }.join
  end
end
