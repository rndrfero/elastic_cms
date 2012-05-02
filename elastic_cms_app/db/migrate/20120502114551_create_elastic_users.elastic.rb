# This migration comes from elastic (originally 20120502114118)
class CreateElasticUsers < ActiveRecord::Migration
  def change
    create_table :elastic_users do |t|
      
      t.string :name
      t.string :email

      t.timestamps
      
    end
  end
end
