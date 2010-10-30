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

  # selection of working days
  def logged_working_days
     self.working_days.find(:all, :order => 'wday desc')  
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

  # Aggregation logic
  def has_late_commings(last_x_days=14)
   lc = logged_working_days.select {|day| day.late_comming? and (Date.today - day.wday < last_x_days)}.length 
   lc if lc > 1
  end

  def has_short_days(last_x_days=14)
   sd = logged_working_days.select {|day| day.short_day? and (Date.today - day.wday < last_x_days)}.length 
   sd if sd > 1
  end
  
  # role validation logic
  def manager?
    false
    true if self.class == Manager
  end
  
end

class Developer < User
  #has_one :manager, through => :group
end

class Manager < User
  has_one :group, :foreign_key => 'manager_id'
  #has_many :developers, :through => :group, foreign_key => 'manager_id'
  
  def weeks_to_analyze
    result = Array.new

    self.group.developers.each do |dev| 
      result += dev.logged_working_weeks
    end
    result.uniq.sort {|a,b| b<=> a}
  end

  def should_worry?
    true unless group.developers.select { |dev| dev.has_late_commings or dev.has_short_days}.empty?
  end
end

class Director < User
  has_and_belongs_to_many :groups
  
end

class Admin < User
end
