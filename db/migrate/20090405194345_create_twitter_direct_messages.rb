class CreateTwitterDirectMessages < ActiveRecord::Migration
  def self.up
    create_table :twitter_direct_messages do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string :text

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_direct_messages
  end
end
