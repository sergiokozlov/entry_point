class AddLoginHomework < ActiveRecord::Migration
  def self.up
    add_column :homeworks, :login, :string
  end

  def self.down
     remove_column :homeworks, :login, :string
  end
end
