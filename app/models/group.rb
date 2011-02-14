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
 
 # Group Statistics
  def week_completed(number = Date.today.cweek)
    self.developers.map{|dev| dev.week_completed(number)}.inject(0) {|x,y| x+y} 
  end

  def week_average(number = Date.today.cweek)
   if (l = self.developers.map{|dev| dev.weeked_working_days(number).length}.inject(0) {|x,y| x+y}) > 0
     week_completed(number)/l
   else
    0
   end 
  end 
end
