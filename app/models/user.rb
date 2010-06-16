class User < ActiveRecord::Base
  has_many :records, :foreign_key => "login", :primary_key => "login"
  has_many :working_days, :foreign_key => "login", :primary_key => "login"
  acts_as_authentic

  # statistics information
  def logged_working_days
     self.working_days.find(:all, :order => 'wday desc')  
  end 

  def weeked_working_days(week_number)
     logged_working_days.select {|day| day.wday.cweek == week_number and day.duration > 0} 
  end 
  
  def working_today
    self.working_days.find(:first, :conditions => {:wday => Date.today})
  end
  
  def logged_working_weeks
    logged_working_days.map{|day| [day.wday.cweek,day.wday.year]}.uniq
  end

  # role validation logic
  def manager?
    false
    true if self.class == Manager
  end

  # setting up user hierarchy
  def set_type_and_manager(arr)
      arr.each do |h|
         
          if h['manager'] == login
            self.type, self.reports_to = 'Manager', nil
          elsif h['developers'].include?(login)
            self.type, self.reports_to = ['Developer',h['manager']]
          end
       end
  end
  
end

class Developer < User
  belongs_to :manager, :foreign_key => :reports_to, :primary_key => :login
end

class Manager < User
  has_many :developers, :foreign_key => :reports_to, :primary_key => :login
  
  def weeks_to_analyze
    result = Array.new

    self.developers.each do |dev| 
      result += dev.logged_working_weeks
    end
    result.uniq
  end
end

class Admin < User
end
