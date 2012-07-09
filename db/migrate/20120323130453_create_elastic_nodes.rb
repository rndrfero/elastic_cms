class CreateElasticNodes < ActiveRecord::Migration
  def change
    create_table :elastic_nodes do |t|
      t.string :title
      t.string :title_loc
      t.string :redirect
      
      t.integer :section_id
      t.string :section_key
      t.integer :site_id
      
      t.string :parent_key
      
      t.text :meta_keywords
      t.text :meta_description
      
      t.string :locale, :limit=>12
      t.string :key
      
      t.boolean :is_star
      t.boolean :is_locked
      t.boolean :is_published
      t.boolean :is_pin
#      t.integer :node_id
      t.integer :position
      
      t.integer :version_cnt
      t.datetime :published_at
      
      t.integer :published_version_id

      t.timestamps
    end
    add_index :elastic_nodes, :key
    add_index :elastic_nodes, :section_id
  end
end
