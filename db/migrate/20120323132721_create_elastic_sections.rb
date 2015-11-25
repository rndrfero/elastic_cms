class CreateElasticSections < ActiveRecord::Migration
  def change
    create_table :elastic_sections do |t|
      t.string :title
      t.integer :position
      
      t.string :localization
      
      t.integer :site_id
      t.string :key

      t.integer :section_id
      
      t.boolean :is_star
      t.boolean :is_hidden
      t.boolean :is_locked
      t.boolean :is_pin
      
      t.string :form

      t.timestamps
    end
    
    add_index :elastic_sections, :key
  end
end
