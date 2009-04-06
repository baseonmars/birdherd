class TwitterStatus < ActiveRecord::Base
  belongs_to :poster, :class_name => "TwitterUser", :foreign_key => "poster_id"
  belongs_to :recipient, :class_name => "TwitterUser", :foreign_key => "in_reply_to_user_id"
  has_many :replies, :class_name => "TwitterStatus", :foreign_key => 'in_reply_to_status_id'
  
  def reply
    replies.new
  end
  
  def update_from_twitter(api_status)
    api_status.instance_variables.each do |attrib|
      if attrib.nil? || attrib == '@user'
        next
      end
      attrib.gsub!(/^@/,'')
      if self.respond_to?(attrib)
        self.send("#{attrib}=", api_status.send(attrib))
      end
    end
    self
  end
  
end
