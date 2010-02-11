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
  def first?
   if self.user.working_days.exists?(:wday => click_date.to_date)
     false
   else
     true
   end
  end

  def tagged_working_day
    self.user.working_days.find(:first, :conditions => {:wday => click_date.to_date})
  end

  # processing logic
  def process 
     if first?
          @processed_day = create_working_day(:login => self.login,:wday => click_date.strftime("%m/%d/%Y"))
          self.working_day = @processed_day
          self.save
     else
          self.working_day = tagged_working_day
          self.save
          self.working_day.recalculate   
     end

  end

end

