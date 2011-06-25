class AddLunchTimeToWorkingDays < ActiveRecord::Migration
  def self.up
    add_column :working_days, :lunch_time, :integer, :default => 45
  end

  def self.down
    remove_column :working_days, :lunch_time, :integer
  end
end
