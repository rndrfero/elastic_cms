class CreateElasticContents < ActiveRecord::Migration
  def change
    create_table :elastic_contents do |t|
      t.text :text
      t.integer :reference_id
      t.string :reference_type
      
      t.text :published_text
      t.integer :published_reference_id
      t.string :published_reference_type
      
      t.integer :content_config_id
      t.string :content_config_key
      t.text :locale      
      t.integer :node_id

      t.timestamps
    end
  end
end
