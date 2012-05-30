class CreateElasticTemplateCaches < ActiveRecord::Migration
  def change
    create_table :elastic_template_caches do |t|
      t.string :key
      t.binary :template

      t.timestamps
    end
    
    add_index :elastic_template_caches, :key
  end
end
