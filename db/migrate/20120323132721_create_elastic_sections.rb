class CreateElasticSections < ActiveRecord::Migration
  def change
    create_table :elastic_sections do |t|
      t.string :title
      
      t.string :localization
      
      t.integer :site_id
      t.string :key
      
      t.boolean :is_locked

      t.timestamps
    end
    
    add_index :elastic_sections, :key
  end
end
