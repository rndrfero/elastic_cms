class CreateElasticSites < ActiveRecord::Migration
  def change
    create_table :elastic_sites do |t|
      t.string :host
      t.string :title
      t.string :key
      t.text :locales
      
      t.string :theme
      t.string :theme_index
      t.string :theme_template
      t.string :theme_layout
      
      t.text :meta_keywords
      t.text :meta_description
    
      t.string :index_locale
      t.text :locale_to_index_hash  

      t.boolean :is_reload_theme
      t.boolean :is_locked

      t.integer :master_gallery_id
      t.integer :master_id
      
      t.integer :bg_gallery_id
      t.string :bg_color
      
      t.boolean :is_reload
      t.boolean :is_star

      
      t.timestamps
    end
    add_index :elastic_sites, :host
  end
end
