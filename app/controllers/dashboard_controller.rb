class DashboardController < ApplicationController
  helper ApplicationHelper # include all helpers, all the time


  def index
    require_user
    @user = current_user
    session[:week] = @week_id = @user.logged_working_weeks.first[0].to_i
  end

  def manage
    require_manager
    @user = current_user

    @weeks  = @user.group.weeks_to_analyze
  end
  
  def overview
    require_director
    @user = current_user
 
    @weeks = @user.groups.first.weeks_to_analyze
  end
  

  #TODO: follow DRY for my_data_for_range and user_data_for_range
  def my_data_for_range
    require_user
    @user = current_user
    @data = Array.new
    
    if params[:id] == 'forward'
      session[:week] += 1
    elsif params[:id] == 'backward'
      session[:week] -= 1
    elsif params[:week]
      session[:week] = params[:week].to_i  
    end
        
    @week_id = (params[:week] || session[:week]).to_i
    
    days_array(7,@template.week_last_day(@week_id) - Date.today).each do |day|
      @data << pj(day,@user)
    end

    @jresult = JSON.generate(["data" => @data])

    render :layout => false
  end
  
  def get_session_week
    @a_result = @template.week_value(session[:week])
    
    render :ajax_result, :layout => false
  end
  
  def team_data_by_week
    require_manager
    @user = current_user
    @selected_group = (Group.find_by_id(params[:group]) || @user.worse_group)
    @week_id  = (params[:week] || (@selected_group.weeks_to_analyze)[0][0]).to_i
 

    render :layout => false 
  end

  def user_data_for_range
    require_manager
    @selected_group = (Group.find_by_id(params[:group]) || current_user.worse_group)
    @dev = @selected_group.developers.find(:first, :conditions => {:id => params[:user].to_i})
    @week_id  = params[:week].to_i
    @data = Array.new

    if @dev 
      days_array(7,@template.week_last_day(@week_id) - Date.today).each do |day|
        @data << pj(day,@dev)
      end
      @jresult = JSON.generate(["data" => @data])
    else
      @jresult = nil  
    end
    render :layout => false
  end

  private

  def pj(day,user)
    if lwd = user.logged_working_days.select{|d| d.wday == day}[0]
      return [[lwd.duration,lwd.homework_duration], {"label" => lwd.label, "bar_label" => lwd.bar_label},
      {"flag" => lwd.color},{"check_in" => lwd.check_in.strftime("%H:%M"),"check_out" =>lwd.check_out.strftime("%H:%M")}]
    else
      return ['', {"label" => day.strftime("%m/%d"),  "bar_label" => ''}, {"flag" => "White"}]
    end
  end
end


