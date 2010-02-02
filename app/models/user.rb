class User < ActiveRecord::Base
  has_many :records, :foreign_key => "login", :primary_key => "login"
  acts_as_authentic  
end
