module TwitterUsersHelper
    
  def twitter_user_link(twitter_user)
    link_to "#{twitter_user.screen_name}",
     "http://twitter.com/#{twitter_user.screen_name}", 
     :title => profile_text(twitter_user)
  end
   
  def twitter_user_profile_image(twitter_user, options={}) 
    unless twitter_user.profile_image_url.blank?
      link_to image_tag(twitter_user.profile_image_url, :alt => ''), 
        "http://twitter.com/#{twitter_user.screen_name}", 
        {:title => profile_text(twitter_user),
        :class => 'profile-image' }.merge(options)
    end
  end
  
  def periodic_list_update(url)
    periodically_call_remote(:url => url,:method => :get, :frequency => 60)
  end 
  
  def render_message(account, message, type, opts={})
    options = { :html_class => ""}.merge opts
    message_type = de_camelize message.class.name     
    render :partial => "#{message_type.pluralize}/#{message_type}", 
           :locals  => {:account => account, 
             :message => message, 
             :type => type, 
             :html_class => options[:html_class]}
  end
  
  private
    def profile_text(twitter_user)
      "Profile for @#{twitter_user.screen_name} (@#{h twitter_user.name})"
    end
end
