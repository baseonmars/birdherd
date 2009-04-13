# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def birdherd_users_string(status)
    users = status.replies.inject([]) { |acc,r| acc << r.birdherd_user }.compact.inject([]){ |acc,u| acc << u.login }.join(', ')
    users.blank? ? "" : "replied to by: " + users
  end
end
