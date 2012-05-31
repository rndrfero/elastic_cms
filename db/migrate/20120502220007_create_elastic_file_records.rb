class CreateElasticFileRecords < ActiveRecord::Migration
  def change
    create_table :elastic_file_records do |t|
      t.string :title
      t.text :text
      
      t.integer :gallery_id
      
      t.string :ino
      t.string :filename
      
      t.integer :is_star

      t.timestamps
    end
  end
end
