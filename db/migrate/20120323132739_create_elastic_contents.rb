class CreateElasticContents < ActiveRecord::Migration
  def change
    create_table :elastic_contents do |t|
      t.text :text
      t.text :published_text
      
      t.integer :content_config_id
#      t.text :meta
      t.text :locale
      
      t.integer :node_id

      t.timestamps
    end
  end
end
