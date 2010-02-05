class WorkingDay < ActiveRecord::Base

 # virtual attributes

  def wday_string  
    wday.strftime("%m/%d/%Y")
  end   
end
