class CreateBlogRecommendations < ActiveRecord::Migration
  def self.up
    create_table :blog_recommendations do |t|
      t.integer :user_id
      t.integer :blog_id
      t.boolean :is_new
      t.boolean :is_rejected
      t.timestamps
    end
  end

  def self.down
    drop_table :blog_recommendations
  end
end
