class AddOauthToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :access_token, :string
    add_column :twitter_users, :access_secret, :string
    remove_column :twitter_users, :password
  end

  def self.down
    add_column :twitter_users, :password, :string
    remove_column :twitter_user, :access_secret
    remove_column :twitter_user, :access_token
  end
end
