class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :blog_id
      t.integer :blog_post_id
      t.integer :num_comments
      t.integer :rating_positive
      t.integer :rating_negative
      t.integer :rating_average
      t.integer :rating_total
      t.text :content
      t.datetime :posted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
