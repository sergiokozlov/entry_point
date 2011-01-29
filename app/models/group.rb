class Group < ActiveRecord::Base
  belongs_to :manager, :foreign_key => 'manager_id'
  has_many :developers

  def weeks_to_analyze
    result = Array.new

    self.developers.each do |dev| 
      result += dev.logged_working_weeks
    end
    result.uniq.sort {|a,b| b<=> a}
  end

  def labels
     h = Hash.new
     self.developers.select {|dev| dev.label}.each {|dev| h[dev.name]= dev.label}
     h
  end
  
end
