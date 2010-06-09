class WorkingDay < ActiveRecord::Base

  has_many :records
 # virtual attributes

  def wday_string  
    wday.strftime("%m/%d/%Y")
  end

  def color
    if duration < 420
      "Red" 
    else
      "Grey"
    end
  end

  def label
    wday.strftime("%m/%d")
    #ApplicationHelper::ABBR_DAYNAMES[wday.wday]
  end

  def bar_label
   if duration > 0 
      hh,mm = duration.divmod(60)
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
  
  
end


