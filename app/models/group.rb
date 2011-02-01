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

  def months_to_analyze
    result = Array.new

    self.developers.each do |dev| 
      result += dev.logged_working_months
    end
    result.uniq.sort {|a,b| b<=> a}
  end

  def alerts
     h = Hash.new
     self.developers.select {|dev| dev.alert}.each {|dev| h[dev.name]= dev.alert}
     h
  end
  
end
