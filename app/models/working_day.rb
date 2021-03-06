class WorkingDay < ActiveRecord::Base
  has_many :records
  has_many :homeworks

  # virtual attributes
  def wday_string  
    wday.strftime("%m/%d/%Y")
  end

  # homework relationship
  def type
   if duration > 0 and homeworks.size > 0
     "normal with homework"
   elsif duration == 0 and homeworks.size > 0
     "just homework"
   else
      "normal"
   end 
  end

  def homework_duration
    homeworks.map {|h| h.duration }.inject(0) {|x,y| x + y}
  end

  # lunch time and duration
  def real_lunch_time
    if duration + homework_duration > ACFG['no_lunch_limit']
      lunch_time
    else
      0
    end
  end

  def total_duration
    td = duration + homework_duration - real_lunch_time
  end

  # manual entries identification
  def has_manual_entries
    false
    self.id if (records.select {|r| r.submit_type == 'manual'} | homeworks).length > 0
  end

  # properties
  
  def weekend?
    true if [6,7].include?(check_in.wday) 
  end 

  def visit_day?
    true if weekend? and total_duration < ACFG['visit_day_limit']
  end

  def short_day?
    true if total_duration < ACFG['short_day_limit'] and duration > 0 and not visit_day?
  end

  def hard_day?
    true if total_duration > ACFG['hard_day_limit'] and duration >0
  end
 
  def late_comming?
    true if check_in.strftime("%H:%M") > ACFG['late_time_limit'] and not visit_day?
  end



  # control javascript UI
  def color
    if short_day?
      "Red"
    elsif hard_day?
      "Green"  
    else
      "Yellow"
    end
  end

  def label
    #wday.strftime("%m/%d")
    ApplicationController.helpers.day_value(wday)
  end

  def bar_label
   if total_duration > 0 
      hh,mm = total_duration.divmod(60)
      mm = '0' + mm.to_s if mm < 10
      return "#{hh}:#{mm}"
   else
    return ''
   end 
  end


  # processing instructions
  def recalculate
    self.check_in = Record.minimum(:click_date, :conditions => {:working_day_id => self.id})
    self.check_out = Record.maximum(:click_date, :conditions => {:working_day_id => self.id})

    self.duration = (self.check_out.to_i - self.check_in.to_i).floor/60
    #big question about saving for "today" activity!
    self.save
  end
    
  def self.stat_refresh(days)
    days.each { |day| day.recalculate  }
  end
  
 def recalculate!
   if self.records.size > 0
     self.recalculate
     self.save
   elsif h = self.homeworks.size > 0
     self.check_in = self.check_out =  h[0].check_in
     self.duration = 0
     self.save
   else
     self.destroy
   end
 end 
end


