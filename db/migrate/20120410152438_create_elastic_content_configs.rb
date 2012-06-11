class CreateElasticContentConfigs < ActiveRecord::Migration
  def change
    create_table :elastic_content_configs do |t|
      t.string :title
      t.string :key
      t.integer :position
      
      t.integer :section_id
      t.string :form
      
      t.text :meta
      
      t.boolean :is_published
      t.boolean :is_live

      t.timestamps
    end
  end
end
