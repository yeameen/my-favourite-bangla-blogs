class AlterUsersPostsAddHash < ActiveRecord::Migration
  def self.up
    add_column :users_posts, :key, :string, :limit => 100
    add_index :users_posts, :key, :unique => true, :name => "hashed_key_index"
  end

  def self.down
    remove_column :users_posts, :key
    remove_index :users_posts, :name => "hashed_key_index"
  end
end
