class Homework < ActiveRecord::Base
  belongs_to :working_day
  # direct link to :user can be added

  # Validation Logic
  # Use Meta programming to follow DRY
  def check_in_string  
     check_in.to_s  
  end  
  
  def check_in_string=(str)
    @blank = str.blank?  
    self.check_in = Time.parse(str)
  rescue ArgumentError  
    @invalid_check_in = true
  end

  
  def check_out_string  
     check_out.to_s  
  end  
  
  def check_out_string=(str)
    @blank = str.blank?  
    self.check_out = Time.parse(str)
  rescue ArgumentError  
    @invalid_check_out = true
  end

  def validate
     errors.add(:check_in, "is invalid") if @invalid_check_in
     errors.add(:check_out, "is invalid") if @invalid_check_out
  end

  def working_day_to_match
    WorkingDay.find(:first, :conditions => {:login => login,:wday => click_date.to_date})
  end


end

