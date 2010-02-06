class CreateWorkingDays < ActiveRecord::Migration
  def self.up
    create_table :working_days do |t|
      t.string :login
      t.datetime :check_in
      t.datetime :check_out
      t.integer :duration
      t.date :wday

      t.timestamps
    end
  end

  def self.down
    drop_table :working_days
  end
end
