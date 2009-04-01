class TwitterUser < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "poster_id"
  
  def self.find_by_status
    
  end
  
end
