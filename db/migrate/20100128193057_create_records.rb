class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.string :login
      t.datetime :click_date
      t.integer :working_day_id
      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
