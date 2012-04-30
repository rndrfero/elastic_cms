# This migration comes from elastic (originally 20120410152438)
class CreateElasticContentConfigs < ActiveRecord::Migration
  def change
    create_table :elastic_content_configs do |t|
      t.string :title
      t.integer :position
      
      t.integer :section_id
      t.string :form
      
      t.string :mime
      t.text :meta
      
      t.boolean :is_offline

      t.timestamps
    end
  end
end
