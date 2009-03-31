class User < ActiveRecord::Base
  has_and_belongs_to_many :twitter_users
  acts_as_authentic
  
end
