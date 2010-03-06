class User < ActiveRecord::Base
  has_many :records, :foreign_key => "login", :primary_key => "login"
  has_many :working_days, :foreign_key => "login", :primary_key => "login"
  acts_as_authentic


  def logged_working_days
     self.working_days.find(:all, :order => 'wday')  
  end 

  def weeked_working_days(week_number)
     logged_working_days.select {|day| day.wday.cweek == week_number} 
  end 

end
