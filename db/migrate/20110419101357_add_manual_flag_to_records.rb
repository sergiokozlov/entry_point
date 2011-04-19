class AddManualFlagToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :submit_type, :string, :default => 'auto'
  end

  def self.down
    remove_column :records, :submit_type, :string
  end
end
