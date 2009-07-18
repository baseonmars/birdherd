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
    
    case
      when  time > 1.minutes.ago;                     "a minute ago"
      when  time > 1.hours.ago;                       "#{minutes_ago} minutes ago"
      when  time > Time.now.at_beginning_of_day;      time.strftime("%I:%M%p")
      when  time > 1.days.ago.at_beginning_of_day;    time.strftime("yesterday at %I:%M%p")
      when  time > 1.weeks.ago.at_beginning_of_day;   time.strftime("%A at %I:%M%p")
      when  time > Time.now.at_beginning_of_month;    time.strftime("%e %B")
      else                                            time.strftime("%e %B, %Y")
    end
    
  end  
  
  def de_camelize(str)
    str.gsub(/([^$])([A-Z])/, '\1_\2').downcase
  end
    
end
