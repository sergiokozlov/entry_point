class Record < ActiveRecord::Base
  belongs_to :working_day
  belongs_to :user, :foreign_key => "login",:primary_key => "login"
  validate   :dates_are_valid?
  validate   :correct_submit_window, :if => "click_date"
  
  
 # virtal attributes
  def click_date_string  
    click_date.to_s  
  end  
  
  def click_date_string=(str)
     self.click_date = DateTime.strptime(str,'%Y-%m-%d %H:%M')
  rescue ArgumentError  
    @invalid = true
  end 
 
  # validation logic  
  def dates_are_valid?
    errors.add_to_base("Date or time provided are invalid") if @invalid
  end
  
  def correct_submit_window
    errors.add_to_base("Record earlier than 45 days from now cannot be added") if (Time.now - click_date)/3600/24 > 45
    errors.add_to_base("Record later than 14 days from now cannot be added") if (click_date - Time.now)/3600/24 > 14
  end

  # assosiation logic
 # def first?
 #  if self.working_day.exists?(:login => self.login, :wday => click_date.to_date)
 #    true
 #  else
 #    false
 #  end
 # end

  def working_day_to_match
    WorkingDay.find(:first, :conditions => {:login => login,:wday => click_date.to_date})
  end

  # processing logic
  def process 
     unless working_day_to_match
          @processed_day = create_working_day(:login => self.login,:wday => click_date.strftime("%m/%d/%Y"))
          self.working_day = @processed_day
          self.save
     else
          self.working_day = working_day_to_match
          self.save
     end
        return @working_day
  end

end

