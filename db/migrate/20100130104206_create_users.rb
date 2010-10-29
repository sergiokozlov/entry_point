class CreateUsers < ActiveRecord::Migration
  def self.up  
    create_table :users do |t|
      t.string :type

      # common attributes  
      t.string :login
      t.string :email
      t.string :name
  
      # auth information  
      t.string :crypted_password  
      t.string :password_salt  
      t.string :persistence_token

      # attributes for type = Developer
      t.integer  :group_id

      # others  
      t.timestamps  
    end  
  end
  

  def self.down
    drop_table :users
  end
end
