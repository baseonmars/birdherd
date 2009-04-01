class TwitterStatus < ActiveRecord::Base
  belongs_to :poster, :class_name => "TwitterUser", :foreign_key => "poster_id"
end
