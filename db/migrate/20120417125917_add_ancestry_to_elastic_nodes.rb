class AddAncestryToElasticNodes < ActiveRecord::Migration
  def self.up
    add_column :elastic_nodes, :ancestry, :string
    add_column :elastic_nodes, :ancestry_depth, :integer
    add_index :elastic_nodes, :ancestry    
  end
  
  def self.down
    remove_column :elastic_nodes, :ancestry
    remove_column :elastic_nodes, :ancestry_depth
    remove_index :elastic_nodes, :ancestry
  end
end
