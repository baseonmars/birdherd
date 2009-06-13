class ConvertTwitterIdsTo64bit < ActiveRecord::Migration
  def self.up
     change_column :twitter_statuses, 'id', :integer, :null => false, :unique => true, :auto_increment => true, :limit => 8
     change_column :twitter_direct_messages, 'id', :integer, :null => false, :unique => true, :auto_increment => true, :limit => 8
     change_column :twitter_users, :friends_timeline_last_id, :integer, :limit => 8
     change_column :twitter_users, :replies_last_id, :integer, :limit => 8
     change_column :twitter_statuses, :in_reply_to_status_id, :integer, :limit => 8
  end

  def self.down
    change_column :twitter_statuses, 'id', :integer, :null => false, :unique => true, :auto_increment => true
    change_column :twitter_direct_messages, 'id', :integer, :null => false, :unique => true, :auto_increment => true    
    change_column :twitter_users, :friends_timeline_last_id, :integer
    change_column :twitter_users, :replies_last_id, :integer
    change_column :twitter_statuses, :in_reply_to_status_id, :integer
  end
end
