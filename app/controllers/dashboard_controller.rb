class DashboardController < ApplicationController
  helper ApplicationHelper # include all helpers, all the time
  
  def index
    session[:point] ||= 0
    require_user
    @user = current_user
  end
 
  def manage
    require_manager
    @user = current_user

    @weeks  = @user.weeks_to_analyze
  end

  #TODO: follow DRY for daily_bars and user_data_for_range
  def daily_bars
    require_user
    @user = current_user
    @data = Array.new

    if params[:id] == 'forward'
      shift = 1
    elsif params[:id] == 'back'
      shift = -1
    else
     shift = 0 
    end

    session[:point] +=shift

   days_array(10,session[:point]).each do |day|
      if lwd = @user.logged_working_days.select{|d| d.wday == day}[0]
  	    @data << [lwd.duration, {"label" => lwd.label, "bar_label" => lwd.bar_label},{"flag" => lwd.color}]
  	  else
  	    @data << ['', {"label" => day.strftime("%m/%d"),  "bar_label" => ''}, {"flag" => "White"}]
  	  end
    end
     @jresult = JSON.generate(["data" => @data])
  
   render :layout => false
  end
  
  def index2
    require_user
    @user = current_user
   
    @data = JSON.generate([1, 2, {"a"=>3.141}, false, true, nil])
    # => "[1,2,{\"a\":3.141},false,true,null,\"4..10\"]"
      
    render :layout => false 
  end
  
  def team_data_by_week
    require_manager
    @user = current_user
    @week_id  = (params[:id] || (@user.weeks_to_analyze)[0][0]).to_i
    
    render :layout => false 
  end

  def user_data_for_range
    require_manager
    @dev = current_user.developers.find(:first, :conditions => {:id => params[:user].to_i})
    @week_id  = params[:week].to_i
    @data = Array.new
    
   if @dev 
    days_array(7,@template.week_last_day(@week_id) - Date.today).each do |day|
      if lwd = @dev.logged_working_days.select{|d| d.wday == day}[0]
  	    @data << [lwd.duration, {"label" => lwd.label, "bar_label" => lwd.bar_label},{"flag" => lwd.color},{"check_in" => lwd.check_in.strftime("%H:%M"),"check_out" =>lwd.check_out.strftime("%H:%M")}]
  	  else
  	    @data << ['', {"label" => day.strftime("%m/%d"),  "bar_label" => ''}, {"flag" => "White"}]
  	  end
    end
     @jresult = JSON.generate(["data" => @data])
   else
     @jresult = nil  
   end
    render :layout => false
  end

end


