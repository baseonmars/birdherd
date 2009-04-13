class AddBirdherdUserId < ActiveRecord::Migration
  def self.up
    add_column :twitter_statuses, :birdherd_user_id, :integer
    add_column :twitter_direct_messages, :birdherd_user_id, :integer
  end

  def self.down
    remove_column :twitter_direct_messages, :birdherd_user_id
    remove_column :twitter_statuses, :birdherd_user_id
  end
end
