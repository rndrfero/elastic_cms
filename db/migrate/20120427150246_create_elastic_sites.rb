class CreateElasticSites < ActiveRecord::Migration
  def change
    create_table :elastic_sites do |t|
      t.string :host
      t.string :title
      t.string :key
      t.text :locales
      
      t.string :theme
      
      t.text :meta_keywords
      t.text :meta_description
    
      t.string :index_locale
      t.text :locale_to_index_hash  

      t.boolean :is_force_reload_theme
      t.boolean :is_locked
      
      t.timestamps
    end
    add_index :elastic_sites, :host
  end
end
