class Homework < ActiveRecord::Base
  belongs_to :working_day
  # direct link to :user can be added
end
