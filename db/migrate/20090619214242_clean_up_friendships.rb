class CleanUpFriendships < ActiveRecord::Migration
  def self.up 
    remove_index :friendships, :friend_id
    remove_index :friendships, :follower_id
    drop_table :friendships            
  end

  def self.down
    create_table "friendships", :force => true do |t|
      t.integer "follower_id"
      t.integer "friend_id"
    end
    add_index :friendships, :follower_id
    add_index :friendships, :friend_id    
  end
end
