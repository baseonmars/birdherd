class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :twitter_user_id
      t.integer :friend_id
    end
  end

  def self.down
    drop_table :friendships
  end
end
