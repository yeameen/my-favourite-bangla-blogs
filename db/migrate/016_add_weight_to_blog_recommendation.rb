class AddWeightToBlogRecommendation < ActiveRecord::Migration
  def self.up
    add_column :blog_recommendations, :weight, :float
  end

  def self.down
    remove_column :blog_recommendations, :weight
  end
end
