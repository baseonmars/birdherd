class AddLastIdsToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :friends_timeline_last_id, :integer
    add_column :twitter_users, :replies_last_id, :integer
    add_column :twitter_users, :sent_dms_last_id, :integer
    add_column :twitter_users, :recieved_dms_last_id, :integer
  end

  def self.down
    remove_column :twitter_users, :recieved_dm_last_id
    remove_column :twitter_users, :sent_dm_last_id
    remove_column :twitter_users, :replies_last_id
    remove_column :twitter_users, :friends_timeline_last_id
  end
end
