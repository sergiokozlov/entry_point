class User < ActiveRecord::Base
  has_many :records, :foreign_key => "login", :primary_key => "login"
  has_many :working_days, :foreign_key => "login", :primary_key => "login"
  acts_as_authentic

  # statistics information
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
    logged_working_days.map{|day| [day.wday.cweek,day.wday.year]}.uniq
  end

  # role validation logic
  def manager?
    false
    true if self.class == Manager
  end

  # setting up user hierarchy [ToBeChanged]
  def self.user_type_manager(login,arr)
      arr.each do |h|
          if h['manager'] == login
            result = ['Manager',nil]
            return result
          elsif h['developers'].include?(login) 
             result = ['Developer',h['manager']]
             return result
          end
       end
   
      result ||= ['User',nil]
  end
  
end

class Developer < User
  belongs_to :manager, :foreign_key => :reports_to, :primary_key => :login
end

class Manager < User
  has_many :developers, :foreign_key => :reports_to, :primary_key => :login
end

class Admin < User
end
