class CreateUsersBlogs < ActiveRecord::Migration
  def self.up
    create_table :users_blogs do |t|
      t.integer :user_id, :null => false
      t.integer :blog_id, :null => false
      t.integer :num_posts
      t.integer :num_new_posts
      t.string :description
      t.string :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :users_blogs
  end
end
