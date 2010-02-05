class Record < ActiveRecord::Base
  belongs_to :working_day
  belongs_to :user, :foreign_key => "login"
  
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
   if self.user.working_days.exist?(:wday_string => click_date.strftime("%m/%d/%Y"))
     true
   else
     false
   end
  end
end
