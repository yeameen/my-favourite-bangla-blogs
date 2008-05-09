class CreateUsersPosts < ActiveRecord::Migration
  def self.up
    create_table :users_posts do |t|
      t.integer :user_id
      t.integer :post_id
      t.integer :num_old_comments
      t.boolean :is_read
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :user_posts
  end
end
