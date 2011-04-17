class Homework < ActiveRecord::Base
  belongs_to :working_day
  belongs_to :user, :foreign_key => "login",:primary_key => "login"
  validate   :dates_are_valid?
  validate :check_in_earlier_than_check_out, :check_in_out_cannot_be_too_far,:correct_submit_window, :if => "check_in and check_out"



  # Use Meta programming to follow DRY
  # Virtual Attributes
  def check_in_string  
     check_in.to_s  
  end  
  
  def check_in_string=(str)
    self.check_in = DateTime.strptime(str,'%Y-%m-%d %H:%M')
  rescue ArgumentError  
    @invalid_check_in = true
  end

  
  def check_out_string  
     check_out.to_s  
  end  
  
  def check_out_string=(str)
    self.check_out = DateTime.strptime(str,'%Y-%m-%d %H:%M')
  rescue ArgumentError  
    @invalid_check_out = true
  end

  # Validation Logic
  def dates_are_valid?
     errors.add_to_base("Check in is invalid") if @invalid_check_in 
     errors.add_to_base("Check out is invalid") if @invalid_check_out
  end

  def check_in_earlier_than_check_out
     errors.add_to_base('Check in should be earlier than check out') if (check_out - check_in) <=0
  end

  def check_in_out_cannot_be_too_far
     errors.add(:check_out, "is more than 24 later than Check in") if  (check_in.next-check_out) <=0
  end

  def correct_submit_window
    errors.add_to_base("Home work earlier than 45 days from now cannot be added") if (Time.now - check_in)/3600/24 > ACFG['submit_window_left']
    errors.add_to_base("Home work later than 14 days from now cannot be added") if (check_in - Time.now)/3600/24 > ACFG['submit_window_right']
  end

 # processing logic
  def working_day_to_match
    WorkingDay.find(:first, :conditions => {:login => login,:wday => check_in.to_date})
  end
 
 
  def process 
     unless working_day_to_match
          @processed_day = create_working_day(:login => self.login,:wday => check_in.strftime("%m/%d/%Y"), :check_in => check_in, :check_out => check_in, :duration => 0)
          self.working_day = @processed_day
     else
          self.working_day = working_day_to_match
     end

     self.duration = (self.check_out - self.check_in)/60
     self.save
  end

end

