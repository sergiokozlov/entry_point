module DashboardHelper

  # Weekly Reports
  
  def week_completed(number = Date.today.cweek)
    @user.weeked_working_days(number).map{|day| day.duration}.inject(0) {|x,y| x+y}  
  end 

  def week_distance
    5*9*60
  end

  def week_to_go(number = Date.today.cweek)
    week_distance - week_completed(number)  
  end
  
  
  def week_average(number = Date.today.cweek)
    week_completed(number)/5
  end
  
  def week_percent
    week_completed*100/week_distance
  end
  
  
  # Daily Reports
  # Today:
  def today_completed
    if @user.working_today
      (Time.now.to_i - @user.working_today.check_in.to_i).floor/60
    else
      0
    end  
  end

  def today_distance
    540
  end

  def today_to_go
    today_distance - today_completed
  end 
  
  def today_percent
    today_completed*100/today_distance
  end
end
