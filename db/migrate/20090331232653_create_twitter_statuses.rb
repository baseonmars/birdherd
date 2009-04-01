class CreateTwitterStatuses < ActiveRecord::Migration
  def self.up
    create_table :twitter_statuses do |t|
      t.text :text
      t.integer :poster_id

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_statuses
  end
end
