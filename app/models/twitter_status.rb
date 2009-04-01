class TwitterStatus < ActiveRecord::Base
  belongs_to :poster, :class_name => "TwitterUser", :foreign_key => "poster_id"
  
  def reply
    TwitterStatus.new
  end
  
end
