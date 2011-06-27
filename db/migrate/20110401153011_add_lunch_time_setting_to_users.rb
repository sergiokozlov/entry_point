class AddLunchTimeSettingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :lunch_time_setting, :integer, :default => 45
  end

  def self.down
    remove_column :users, :lunch_time_setting, :integer
  end
end
