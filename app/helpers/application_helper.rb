module ApplicationHelper
  def display_flash_messages
    html = ""
    flash.each do |key, msg|
      case key
      when "notice"
        html += content_tag :div, msg, class: "alert alert-info"
      else
        html += content_tag :div, msg, class: "alert alert-warning"
      end
    end
    html
  end
end
