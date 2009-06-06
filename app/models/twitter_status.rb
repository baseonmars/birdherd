class TwitterStatus < ActiveRecord::Base
  belongs_to :poster, :class_name => "TwitterUser", :foreign_key => "poster_id"
  belongs_to :recipient, :class_name => "TwitterUser", :foreign_key => "in_reply_to_user_id"
  belongs_to :birdherd_user, :class_name => 'User', :foreign_key => 'birdherd_user_id'
  has_many :replies, :class_name => "TwitterStatus", :foreign_key => 'in_reply_to_status_id'

  acts_as_taggable_on :tags
  
  def reply
    TwitterStatus.new(:in_reply_to_status_id => id, :text => "@#{poster.screen_name} ")
  end

  # TODO - remove
  def update_from_twitter(api_status)
    TwitterStatus.merge(api_status)
  end

  def self.merge(api_status)
    status = TwitterStatus.find_or_initialize_by_id(api_status.id)
    api_status.each { |k,v| status.send("#{k}=", v) if status.respond_to?("#{k}=") }
    status.poster = TwitterUser.merge(api_status.user)
    status
  end    
  
  def self.friends_timeline(account_api)
    account_api.friends_timeline.collect do |api_status|
      status = TwitterStatus.merge(api_status)   
      status.save
      status
    end                             
  end    

end
