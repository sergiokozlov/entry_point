class Group < ActiveRecord::Base
  belongs_to :manager, :foreign_key => 'manager_id'
  has_many :developers

  def weeks_to_analyze
    result = Array.new

    self.developers.each do |dev| 
      result += dev.logged_working_weeks
    end
    result.uniq.sort {|a,b| b.reverse <=> a.reverse}
  end

  def months_to_analyze
    result = Array.new

    self.developers.each do |dev| 
      result += dev.logged_working_months
    end
    result.uniq.sort {|a,b| b.reverse <=> a.reverse}
  end

  def alerts
     h = Hash.new
     self.developers.select {|dev| dev.alert}.each {|dev| h[dev.name]= dev.alert}
     h
  end
 
 # Group Statistics
  def day_completed(day = Date.today)
    self.developers.map {|dev| l=dev.logged_working_days.select{|d| d.wday == day}[0]
      (l.duration if l) || 0}.inject(0) {|x,y| x+y} 
  end  

  def day_average(day = Date.today)
   i=0
   self.developers.each{ |dev| i+=1 if dev.logged_working_days.select{|d| d.wday == day}}
   if i > 0
     day_completed(day)/i
   else
     0
   end  
  end
  
  def week_completed(number = Date.today.cweek, year = Date.today.year)
    self.developers.map{|dev| dev.week_completed(number, year)}.inject(0) {|x,y| x+y} 
  end

  def week_average(number = Date.today.cweek, year = Date.today.year)
   if (l = self.developers.map{|dev| dev.weeked_working_days(number, year).length}.inject(0) {|x,y| x+y}) > 0
     week_completed(number, year)/l
   else
    0
   end 
  end 

  def month_completed(number = Date.today.month, year = Date.today.year)
    self.developers.map{|dev| dev.month_completed(number, year)}.inject(0) {|x,y| x+y} 
  end

  def month_average(number = Date.today.month, year = Date.today.year)
   if (l = self.developers.map{|dev| dev.month_working_days(number, year).length}.inject(0) {|x,y| x+y}) > 0
     month_completed(number, year)/l
   else
    0
   end 
  end 
end
