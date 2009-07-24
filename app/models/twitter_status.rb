class TwitterStatus < ActiveRecord::Base
  belongs_to :sender, :class_name => "TwitterUser", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "TwitterUser", :foreign_key => "in_reply_to_user_id"
  belongs_to :birdherd_user, :class_name => 'User', :foreign_key => 'birdherd_user_id'
  has_many :replies, :class_name => "TwitterStatus", :foreign_key => 'in_reply_to_status_id'
  
  def reply
    TwitterStatus.new(:in_reply_to_status_id => id, :text => "@#{sender.screen_name} ")
  end

  # TODO - remove
  def update_from_twitter(api_status)
    TwitterStatus.merge(api_status)
  end                        
  
  def update_from_api(api_status)
    api_status.delete :id
    api_status.each { |k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") }
    self.sender = TwitterUser.merge(api_status.user)
    self.save if self.changed?
    self
  end

  def self.merge(api_status)                                     
    return nil if api_status.nil?
    status = TwitterStatus.find_or_initialize_by_id(api_status.id) 
    api_status.each { |k,v| status.send("#{k}=", v) if status.respond_to?("#{k}=") }
    status.sender = TwitterUser.merge(api_status.user)
    status.save if  status.new_record? or status.changed?
    status
  end
  
  def self.merge_all(api_result) 
    return [] if api_result.nil?
    # TODO check response for errors
    ids = api_result.collect { |status| status[:id] }
    messages = TwitterStatus.all :conditions => "id in (#{ids.join(',')})", :include => [:replies, :sender]
    api_result.collect do |api_message|
      if message = messages.find { |m| m.id == api_message.id}
        message.update_from_api api_message
      else 
        self.merge api_message
      end
    end    
  end
    
  def poster
    @sender
  end
  
  def poster=(twitter_user)
    @sender = twitter_user
  end
  
                       
end
