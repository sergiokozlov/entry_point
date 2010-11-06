class CreateDirectorGroup < ActiveRecord::Migration
  def self.up
    create_table :directors_groups, :id => false do |t|
      t.integer :group_id
      t.string :director_id

      t.timestamps
    end
  end

  def self.down
    drop_table :directors_groups
  end
end
