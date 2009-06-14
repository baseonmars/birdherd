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
    (direct_messages_sent[0...15] + 
      direct_messages_recieved[0...15]).sort {|a,b| b.created_at <=> a.created_at}
  end
  
  def mentions
     TwitterStatus.merge_all account_api.replies(:limit => 30)
  end

  def owned_by?(user)
    users.include? user unless users.nil?
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

  def update_relationships(type, api_user_ids)
    users = []
    api_user_ids.each do |api_id|
      user = TwitterUser.find_or_initialize_by_id(api_id)
      users << user
    end
    self.send("#{type}s").replace(users)
    self
  end

  def visible_to?(other)
    unprotected || followers.include?(other)
  end 

  protected
    attr_accessor :timeline_limit           

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


