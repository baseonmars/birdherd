# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def reply_users_string(status)
    users = status.replies.inject([]) { |acc,r| acc << r.birdherd_user }.compact
    reply_string = users.inject([]){ |acc,u| acc << "#{u.login} (#{u.email})" }.join(', ')
    users.blank? ? "" : reply_string
  end
  
  def friendly_time(time)
    
    seconds_ago = Time.now - time
    minutes_ago = (seconds_ago / 60).to_i

    if time > 1.minutes.ago
      return "a minute ago"
    elsif time > 1.hours.ago
      return "#{minutes_ago} minutes ago"
    elsif time > Time.now.at_beginning_of_day
      return time.strftime("%I:%M%p")
    elsif time > 1.days.ago.at_beginning_of_day
      return time.strftime("yesterday at %I:%M%p")
    elsif time > 1.weeks.ago.at_beginning_of_day
      return time.strftime("%A at %I:%M%p")
    elsif time > Time.now.at_beginning_of_month
      return time.strftime("%e %B")
    else
      return time.strftime("%e %B, %Y")
    end
    
  end
    
end
