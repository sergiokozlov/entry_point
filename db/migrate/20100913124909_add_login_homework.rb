class AddLoginHomework < ActiveRecord::Migration
  def self.up
    add_column :homeworks, :login, :string
    add_column :homeworks, :duration, :integer
    add_column :homeworks, :status, :string 
  end

  def self.down
     remove_column :homeworks, :login, :string
     remove_column :homeworks, :duration, :integer
     remove_column :homeworks, :status, :string
  end
end
