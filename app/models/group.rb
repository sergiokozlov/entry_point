class Group < ActiveRecord::Base
  has_one :manager, :foreign_key => 'manager_id'
  has_many :developers
end
