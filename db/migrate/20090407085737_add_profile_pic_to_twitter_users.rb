class AddProfilePicToTwitterUsers < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :profile_image_url, :string
  end

  def self.down
    remove_column :twitter_users, :profile_image_url
  end
end
