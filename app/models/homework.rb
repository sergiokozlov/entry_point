class Homework < ActiveRecord::Base
  belongs_to :working_day
  belongs_to :user, :foreign_key => "login",:primary_key => "login"
  validate   :check_in_out_validity, :check_in_earlier_than_check_out, :check_in_out_cannot_be_too_far



  # Use Meta programming to follow DRY
  # Virtual Attributes
  def check_in_string  
     check_in.to_s  
  end  
  
  def check_in_string=(str)
    @blank_check_in = str.blank?  
    self.check_in = DateTime.parse(str)
  rescue ArgumentError  
    @invalid_check_in = true
  end

  
  def check_out_string  
     check_out.to_s  
  end  
  
  def check_out_string=(str)
    @blank_check_out = str.blank?  
    self.check_out = DateTime.parse(str)
  rescue ArgumentError  
    @invalid_check_out = true
  end

  # Validation Logic
  def check_in_out_validity
     errors.add(:check_in, "is invalid") if @invalid_check_in or @blanck_check_in
     errors.add(:check_out, "is invalid") if @invalid_check_out or @blanck_check_out
  end

  def check_in_earlier_than_check_out
     errors.add(:check_in, 'should be earlier than check out') if (check_out - check_in) <=0
  end

  def check_in_out_cannot_be_too_far
   unless check_in.strftime("%m/%d/%Y") == check_out.strftime("%m/%d/%Y") or check_in.next.strftime("%m/%d/%Y") == check_out.strftime("%m/%d/%Y")
     errors.add(:check_in, "cannot be that far from Check out time")
   end 
  end


 # processing logic
  def working_day_to_match
    WorkingDay.find(:first, :conditions => {:login => login,:wday => check_in.to_date})
  end

 
  def process 
     unless working_day_to_match
          @processed_day = create_working_day(:login => self.login,:wday => check_in.strftime("%m/%d/%Y"))
          self.working_day = @processed_day
     else
          self.working_day = working_day_to_match
     end

     self.duration = (self.check_out - self.check_in)/60
     self.save
  end

end

