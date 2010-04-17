class User < ActiveRecord::Base
  has_many :records, :foreign_key => "login", :primary_key => "login"
  has_many :working_days, :foreign_key => "login", :primary_key => "login"
  acts_as_authentic


  def logged_working_days
     self.working_days.find(:all, :order => 'wday desc')  
  end 

  def weeked_working_days(week_number)
     logged_working_days.select {|day| day.wday.cweek == week_number} 
  end 
  
  def working_today
    self.working_days.find(:first, :conditions => {:wday => Date.today})
  end
  
  def logged_working_weeks
    logged_working_days.map{|day| day.wday.cweek}.uniq
  end
  
end

class Developer < User
  belongs_to :manager, :foreign_key => :reports_to
end

class Manager < User
end

class Admin < User
end
