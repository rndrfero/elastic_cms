# This migration comes from elastic (originally 20120323130453)
class CreateElasticNodes < ActiveRecord::Migration
  def change
    create_table :elastic_nodes do |t|
      t.string :title
      t.string :title_loc
      t.string :link
      
      t.integer :section_id
      t.integer :site_id
      
      t.text :meta_keywords
      t.text :meta_description
      
      t.string :locale
      t.string :key
      
      t.boolean :is_star
      t.boolean :is_published
      t.integer :node_id
      t.integer :position

      t.timestamps
    end
    add_index :elastic_nodes, :key
    add_index :elastic_nodes, :section_id
  end
end
