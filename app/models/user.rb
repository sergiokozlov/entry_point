class User < ActiveRecord::Base
  has_many :records, :foreign_key => "login", :primary_key => "login"
  has_many :homeworks, :foreign_key => "login", :primary_key => "login"
  has_many :working_days, :foreign_key => "login", :primary_key => "login"
  acts_as_authentic

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
    result.uniq.sort {|a,b| b<=> a}
  end

  def should_worry?
    true unless developers.select { |dev| dev.has_late_commings or dev.has_short_days}.empty?
  end
end

class Admin < User
end
