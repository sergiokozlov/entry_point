class User < ActiveRecord::Base
  acts_as_authentic
  
  before_validation_on_create :set_login_from_name, :set_email_from_name, :set_default_password
  validates_numericality_of :lunch_time_setting, :only_integer => true, :message => "Lunch time should be Integer Number"


  has_many :records, :foreign_key => "login", :primary_key => "login"
  has_many :homeworks, :foreign_key => "login", :primary_key => "login"
  has_many :working_days, :foreign_key => "login", :primary_key => "login"
  belongs_to :group


  # validations
  # lunch_time 
 

  # setting login and email from User Name and default password during initial user creation
  def set_login_from_name
    self.login = (name.split(' ')[0][0,1] + name.split(' ')[1]).downcase unless login
  end

  def set_email_from_name
    self.email = (name.split(' ')[0][0,1] + name.split(' ')[1]).downcase + '@enkata.com' unless email
  end

  def set_default_password
    self.password = self.password_confirmation = 'Password10' unless password
  end

  # selection of working days for week and month
  def logged_working_days
     self.working_days 
  end 

  def month_working_days(month_number, year)
     self.working_days.select {|day| day.wday.month == month_number and day.wday.year == year and day.total_duration > 0}
  end
  
  def weeked_working_days(week_number, year)
     self.working_days.select {|day| day.wday.cweek == week_number and day.wday.year == year and day.total_duration > 0} 
  end 
  
  def working_today
    self.working_days.find(:first, :conditions => {:wday => Date.today})
  end
  
  def logged_working_weeks
    self.working_days.map{|day| [day.wday.cweek,day.wday.year]}.uniq.sort {|a,b| b.reverse <=> a.reverse }
  end

  def logged_working_months
    self.working_days.map{|day| [day.wday.month,day.wday.year]}.uniq {|a,b| b.reverse <=> a.reverse }
  end

  # Statitics
  def week_completed (number=Date.today.cweek, year = Date.today.year)
    weeked_working_days(number, year).select{|day| not day.visit_day?}.map{|day| day.total_duration}.inject(0) {|x,y| x+y}
  end

  def week_average (number=Date.today.cweek, year = Date.today.year)
    if (l = weeked_working_days(number, year).select{|day| not day.visit_day?}.length) > 0
  #  if week_completed(number,year) > 0  
      week_completed(number, year)/l
    else
      0
    end
  end

  def month_completed (number=Date.today.month, year = Date.today.year)
    month_working_days(number, year).select{|day| not day.visit_day?}.map{|day| day.total_duration}.inject(0) {|x,y| x+y}
  end

  def month_average (number=Date.today.month, year = Date.today.year)
    if (l = month_working_days(number, year).select{|day| not day.visit_day?}.length) > 0
      month_completed(number, year)/l
    else
      0
    end
  end

  # Aggregation logic
  def has_late_commings(last_x_days=14)
   lc = self.working_days.select {|day| day.late_comming? and (Date.today - day.wday < last_x_days)}.length 
   message =  "came late #{lc} times" if lc > 1
   #lc if lc > 1
  end

  def has_short_days(last_x_days=14)
   sd = self.working_days.select {|day| day.short_day? and (Date.today - day.wday < last_x_days)}.length
   message = "had #{sd} short days" if sd > 1
   #sd if sd > 1
  end

  def alert
    [has_late_commings,has_short_days].select {|a| a}.inject() {|x,y| x + ' and ' + y}
  end
  
  # role validation logic
  def manager?
    false
    true if self.class == Manager
  end
  
  def director?
    false
    true if self.class == Director    
  end
  
  # sign-in validation logic
  def person?
    false
    true unless working_days.empty?
  end
end  

class Developer < User
  #has_one :manager, through => :group
end

class Manager < User
  has_one :group, :foreign_key => 'manager_id'
  #has_many :developers, :through => :group, foreign_key => 'manager_id'

  def should_worry?
    true unless group.alerts.empty?
  end

  def worse_group
    group
  end
end

class Director < User
  has_and_belongs_to_many :groups

  def worse_group
    groups.first
  end

end

class Admin < User
end
