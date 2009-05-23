class AddIndexesToJoinTables < ActiveRecord::Migration
  def self.up
    add_index :friendships, :follower_id
    add_index :friendships, :friend_id
    
    add_index :twitter_direct_messages, :sender_id
    add_index :twitter_direct_messages, :recipient_id
    add_index :twitter_direct_messages, :birdherd_user_id
    
    add_index :twitter_statuses, :poster_id
    add_index :twitter_statuses, :birdherd_user_id
    
    add_index :twitter_users_users, :user_id
    add_index :twitter_users_users, :twitter_user_id
    
    
  end

  def self.down
    remove_index :twitter_users_users, :twitter_user_id    
    remove_index :twitter_users_users, :user_id

    remove_index :twitter_statuses, :birdherd_user_id
    remove_index :twitter_statuses, :poster_id
    
    remove_index :twitter_direct_messages, :birdherd_user_id
    remove_index :twitter_direct_messages, :recipient_id
    remove_index :twitter_direct_messages, :sender_id
    
    remove_index :friendships, :friend_id
    remove_index :friendships, :follower_id
  end
end
