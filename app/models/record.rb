class Record < ActiveRecord::Base
  belongs_to :working_day
  belongs_to :user, :foreign_key => "login",:primary_key => "login"
  
  validate :click_date_emptiness, :message => "Entered Date is Empty"

 # virtal attributes
  def click_date_string  
    click_date.to_s  
  end  
  
  def click_date_string=(str)
    @blank = str.blank?  
    self.click_date = Time.parse(str)
  rescue ArgumentError  
    @invalid = true
  end 
 
  # validation logic  
  def click_date_emptiness
     errors.add(:click_date, "is empty") if @blank
  end

  def validate
     errors.add("Entered Date") if @invalid
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

