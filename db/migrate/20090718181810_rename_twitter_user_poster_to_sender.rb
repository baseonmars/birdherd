class RenameTwitterUserPosterToSender < ActiveRecord::Migration
  def self.up 
    rename_column :twitter_statuses, :poster_id, :sender_id
  end

  def self.down
    rename_column :twitter_statuses, :sender_id, :poster_id
  end
end
