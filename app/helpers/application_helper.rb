# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def reply_users_string(status)
    users = status.replies.inject([]) { |acc,r| acc << r.birdherd_user }.compact
    reply_string = users.inject([]){ |acc,u| acc << "#{u.login} (#{u.email})" }.join(', ')
    users.blank? ? "" : reply_string
  end
  
  def friendly_time(time)
    time.strftime("%H:%M %a %B %Y")
  end
    
end
