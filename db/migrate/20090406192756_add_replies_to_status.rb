class AddRepliesToStatus < ActiveRecord::Migration
  def self.up
    add_column :twitter_statuses, :in_reply_to_status_id, :integer
  end

  def self.down
    remove_column :twitter_statuses, :in_reply_to_status_id
  end
end
