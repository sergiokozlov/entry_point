module DashboardHelper

  def week_completed(number)
    @user.weeked_working_days(number).map{|day| day.duration}.inject(0) {|x,y| x+y}  
  end 

  def week_distance
    2700
  end


  def week_to_go(number)
    week_distance - week_completed(number)  
  end
end
