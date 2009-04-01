class CreateTwitterUsers < ActiveRecord::Migration
  def self.up
    create_table :twitter_users do |t|
      t.string :password
      t.string :screen_name
      t.date :last_pulled

      t.timestamps
    end
    
    create_table :twitter_users_users, :force => true do |t|
      t.integer :user_id
      t.integer :twitter_user_id
    end
    
    remove_column :twitter_users_users, :id
  end

  def self.down
    drop_table :twitter_users_users
    drop_table :twitter_users
  end
end
