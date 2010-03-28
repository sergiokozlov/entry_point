class DashboardController < ApplicationController

  def index
    require_user
    @user = current_user
  end
  
  def daily_bars
    require_user
    @user = current_user  
    bars_data = "["

    days_array(10,params[:id].to_i||0).each do |day|
	  if lwd = @user.logged_working_days.select{|d| d.wday == day}[0]
	    bars_data << %Q/[#{lwd.duration},{"label":"#{lwd.label}"}, {"flag":"#{lwd.color}"}],/
	  else
	    bars_data << '[0, {"label": ""}, {"flag": "White"}],'
	  end
	end

	bars_data << '[0, {"label": ""}, {"flag": "White"}]]'
    
    @data = %Q/{
      "message": "Hi There",
      "data": #{bars_data}
    }/
 
   render :layout => false
  end
  
  def index2
    require_user
    @user = current_user   
  end

end


