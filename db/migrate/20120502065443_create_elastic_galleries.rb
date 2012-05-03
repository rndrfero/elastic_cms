class CreateElasticGalleries < ActiveRecord::Migration
  def change
    create_table :elastic_galleries do |t|
      t.string :title
      t.string :key
      
      t.integer :site_id
      t.integer :node_id
      
      t.boolean :is_star
      t.boolean :is_watermarked
      
      t.text :meta
      
      t.timestamps
    end
    add_index :elastic_galleries, :site_id
    
    add_column :elastic_sites, :galleries_meta, :text
  end
end