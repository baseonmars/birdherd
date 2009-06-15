class TwitterUser < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "poster_id"

  has_many :follower_friendships, :class_name => 'Friendship',  :foreign_key => 'follower_id'
  has_many :followers, :class_name            => 'TwitterUser', :through     => :friend_friendships, :source => :follower
  has_many :friend_friendships, :class_name   => 'Friendship',  :foreign_key => 'friend_id'
  has_many :friends, :class_name              => 'TwitterUser', :through     => :follower_friendships, :source => :friend
                    
  def friends_timeline
    TwitterStatus.merge_all account_api.friends_timeline(:limit => 30)
  end
  
  def direct_messages_sent
    TwitterDirectMessage.merge_all account_api.direct_messages_sent(:limit => 30)
  end
  
  def direct_messages_recieved
    TwitterDirectMessage.merge_all account_api.direct_messages(:limit => 30)
  end
  
  def direct_messages
    messages = (direct_messages_sent + direct_messages_recieved).sort {|a,b| b.created_at <=> a.created_at}
    messages[0...30]
  end
  
  def mentions
     TwitterStatus.merge_all account_api.replies(:limit => 30)
  end
  
  def post_update(tweet, bh_user)
    if tweet.text =~ /^d \w+\s/
      user, text = tweet.text.scan(/^d (\w+) (.*)/).flatten
      api_message = account_api.direct_message_create(user, text)
      message = TwitterDirectMessage.merge api_message
      message.birdherd_user = bh_user
      message.save
      return message
    else
      api_status = account_api.update( tweet.text,
        :in_reply_to_status_id => tweet.in_reply_to_status_id,
        :source => 'birdherd' )
      status = TwitterStatus.merge api_status
      status.birdherd_user = bh_user
      status.save
      return status
    end  
  end

  def owned_by?(user)
    users.include? user unless users.nil?
  end 
  
  def verify_credentials
    TwitterUser.merge account_api.verify_credentials
  end
  
  def self.verify_and_merge(token, secret)
    user = new(:access_token => token, :access_secret => secret)
    user.verify_credentials
  end
    
  def merge!(api_user)
    raise "Id's do not match" if id != api_user[:id]
    return if api_user.nil?
    api_user.each { |k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") }
  end
              
  # TODO - remove
  def update_from_twitter(api_user)
     TwitterUser.merge api_user
  end 

  def self.merge(api_user)
    return if api_user.nil?
    user = TwitterUser.find_or_initialize_by_id(api_user.id)
    api_user.each { |k,v| user.send("#{k}=", v) if user.respond_to?("#{k}=") } 
    user.save if user.new_record? or user.changed?
    user
  end 

  def visible_to?(other)
    unprotected || followers.include?(other)
  end

  private     
          
    def unprotected
      !self.protected
    end  
    
    def oauth_client
      Twitter::OAuth.new(SITE[:api_key], SITE[:api_secret])
    end

    def account_api
      oauth = oauth_client
      oauth.authorize_from_access(access_token, access_secret)
      Twitter::Base.new(oauth)
    end     

end


