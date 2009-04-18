module TwitterUsersHelper
    
  def twitter_user_link(twitter_user)
    link_to "@#{twitter_user.screen_name}",
     "http://twitter.com/#{twitter_user.screen_name}", 
     :alt => profile_text(twitter_user),
     :title => profile_text(twitter_user)
  end
   
  def twitter_user_profile_image(twitter_user)
    unless twitter_user.profile_image_url.blank?
      link_to image_tag(twitter_user.profile_image_url), 
        "http://twitter.com/#{twitter_user.screen_name}", 
        :alt => profile_text(twitter_user),
        :title => profile_text(twitter_user),
        :class => 'profile-image' 
    end
  end
  
  private
    def profile_text(twitter_user)
      "@#{twitter_user.screen_name}'s profile"
    end
end
