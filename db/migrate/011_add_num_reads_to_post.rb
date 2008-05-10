class AddNumReadsToPost < ActiveRecord::Migration
  def self.up
    add_column :sites, :xpath_num_reads, :string
    add_column :posts, :num_reads, :integer
  end

  def self.down
    remove_column :sites, :xpath_num_reads
    remove_column :posts, :num_reads
  end
end
