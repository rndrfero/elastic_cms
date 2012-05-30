# This migration comes from elastic (originally 20120323132721)
class CreateElasticSections < ActiveRecord::Migration
  def change
    create_table :elastic_sections do |t|
      t.string :title
      
      t.string :localization
      
      t.integer :site_id
      t.string :key
      
      t.boolean :is_star
      t.boolean :is_hidden
      t.boolean :is_locked
      
      t.string :form

      t.timestamps
    end
    
    add_index :elastic_sections, :key
  end
end
