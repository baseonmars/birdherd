class TwitterStatus < ActiveRecord::Base
  belongs_to :poster, :class_name => "TwitterUser", :foreign_key => "poster_id"
  belongs_to :recipient, :class_name => "TwitterUser", :foreign_key => "in_reply_to_user_id"
  belongs_to :birdherd_user, :class_name => 'User', :foreign_key => 'birdherd_user_id'
  has_many :replies, :class_name => "TwitterStatus", :foreign_key => 'in_reply_to_status_id'

  acts_as_taggable_on :tags
  
  def reply
    replies.new(:text => "@#{poster.screen_name} ")
  end

  def update_from_twitter(api_status)
    api_status.each { |k,v| self.send("#{k}=", v) if self.respond_to?(k) }
    self
  end

end
