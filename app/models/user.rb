class User < ActiveRecord::Base
  
  before_validation :set_login_from_name, :set_email_from_name, :set_default_password, :on => :save

  has_many :records, :foreign_key => "login", :primary_key => "login"
  has_many :homeworks, :foreign_key => "login", :primary_key => "login"
  has_many :working_days, :foreign_key => "login", :primary_key => "login"
  belongs_to :group

  acts_as_authentic

 

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
     self.working_days.find(:all, :order => 'wday desc')  
  end 

  def month_working_days(month_number)
     logged_working_days.select {|day| day.wday.month == month_number and day.total_duration > 0}
  end
  
  def weeked_working_days(week_number)
     logged_working_days.select {|day| day.wday.cweek == week_number and day.total_duration > 0} 
  end 
  
  def working_today
    self.working_days.find(:first, :conditions => {:wday => Date.today})
  end
  
  def logged_working_weeks
    logged_working_days.map{|day| [day.wday.cweek,day.wday.year]}.uniq
  end

  def logged_working_months
    logged_working_days.map{|day| [day.wday.month,day.wday.year]}.uniq
  end

  # Statitics
  def week_completed (number=Date.today.cweek)
    weeked_working_days(number).map{|day| day.total_duration}.inject(0) {|x,y| x+y}
  end

  def week_average (number=Date.today.cweek)
    if (l = weeked_working_days(number).length) > 0
      week_completed(number)/l
    else
      0
    end
  end

  def month_completed (number=Date.today.month)
    month_working_days(number).map{|day| day.total_duration}.inject(0) {|x,y| x+y}
  end

  def month_average (number=Date.today.month)
    if (l = month_working_days(number).length) > 0
      month_completed(number)/l
    else
      0
    end
  end

  # Aggregation logic
  def has_late_commings(last_x_days=14)
   lc = logged_working_days.select {|day| day.late_comming? and (Date.today - day.wday < last_x_days)}.length 
   message =  " came late #{lc} times" if lc > 1
   #lc if lc > 1
  end

  def has_short_days(last_x_days=14)
   sd = logged_working_days.select {|day| day.short_day? and (Date.today - day.wday < last_x_days)}.length
   message = "worked #{sd} short days" if sd > 1  
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
