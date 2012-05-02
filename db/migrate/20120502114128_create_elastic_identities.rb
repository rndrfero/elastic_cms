class CreateElasticIdentities < ActiveRecord::Migration
  def change
    create_table :elastic_identities do |t|
      
      t.string :uid
      t.string :provider
      t.integer :user_id
      t.string :password_digest
      t.string :email
      
      t.timestamps
    end
    add_index :elastic_identities, :user_id
  end
end
