class CreateHomeworks < ActiveRecord::Migration
  def self.up
    create_table :homeworks do |t|
      t.datetime :check_in
      t.datetime :check_out
      t.integer :working_day_id
      t.integer :order_id
      t.timestamps
    end
  end

  def self.down
    drop_table :homeworks
  end
end
