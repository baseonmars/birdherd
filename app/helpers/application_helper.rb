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
  
  def account_menu(active_account, user)    
    acc_list = user.twitter_users.sort_by {|tu| tu.screen_name}

    if active = acc_list.delete(active_account)
      acc_list.unshift active
    else
      active = acc_list.first 
    end

    acc_list_html = acc_list.inject("") do |list,account| 
      list << content_tag(:li, link_to(account.screen_name, twitter_user_path(account)), 
      :class => account.screen_name.eql?(active.screen_name) ? 'current' : '')
    end

    content_tag(:ul,acc_list_html, :class => 'account-list')
  end
    
end
