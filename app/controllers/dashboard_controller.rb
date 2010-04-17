class DashboardController < ApplicationController

  def index
    session[:point] ||= 0
    require_user
    @user = current_user
  end
 
  def manage
    require_manager
    @user = current_user
  end

  def daily_bars
    require_user
    @user = current_user

    if params[:id] == 'forward'
      shift = 1
    elsif params[:id] == 'back'
      shift = -1
    else
     shift = 0 
    end

    session[:point] +=shift
    bars_data = "["

    days_array(10,session[:point]).each do |day|
	  if lwd = @user.logged_working_days.select{|d| d.wday == day}[0]
	    bars_data << %Q/[#{lwd.duration},{"label":"#{lwd.label}"}, {"flag":"#{lwd.color}"}],/
	  else
	    bars_data << '[0, {"label": ""}, {"flag": "White"}],'
	  end
	end

    bars_data[-1]=']'
    
    @data = %Q/{
      "message": "#{days_array(5,session[:point]).length}",
      "point": "#{session[:point]}",
      "data": #{bars_data}
    }/
 
   render :layout => false
  end
  
  def index2
    require_user
    @user = current_user   
  end


end


