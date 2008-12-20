class AlterSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :xpath_positive_rating, :string
    add_column :sites, :xpath_negative_rating, :string
    add_column :sites, :positive_rating_position, :integer
    add_column :sites, :negative_rating_position, :integer
    add_column :sites, :num_comment_position, :integer
    add_column :sites, :num_read_position, :integer
  end

  def self.down
    remove_column :sites, :num_read_position
    remove_column :sites, :num_comment_position
    remove_column :sites, :negative_rating_position
    remove_column :sites, :positive_rating_position
    remove_column :sites, :xpath_negative_rating
    remove_column :sites, :xpath_positive_rating
  end
end
