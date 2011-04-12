class DashboardController < ApplicationController
  helper ApplicationHelper # include all helpers, all the time
  before_filter :store_location, :only => [:index, :manage, :overview]

  def index
    require_user
    @user = current_user
    session[:week] = @week_id = @user.logged_working_weeks.first[0].to_i
  end

  def manage
    require_manager
    @user = current_user
    @group = @user.group

    @weeks  = @group.weeks_to_analyze
    @months = @group.months_to_analyze
  end
  
  def overview
    require_director
    @user = current_user
 
    @weeks = @user.groups.first.weeks_to_analyze
    @months = @user.groups.first.months_to_analyze
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
    @first_week = current_user.logged_working_weeks.last[0].to_i
    @last_week = current_user.logged_working_weeks.first[0].to_i
    
    render :ajax_result, :layout => false
  end
  
  def team_data_by_week
    require_manager
    @user = current_user
    @selected_group = (Group.find_by_id(params[:group]) || @user.worse_group)
    @week_id  = (params[:week] || (@selected_group.weeks_to_analyze)[0][0]).to_i
    
    case 
    when (@user.director? and @selected_group.manager.person?)
       @developers = [@selected_group.manager] + @selected_group.developers
    else
       @developers = @selected_group.developers
    end
 

    render :layout => false 
  end

    def team_data_by_month
    require_manager
    @user = current_user
    @selected_group = (Group.find_by_id(params[:group]) || @user.worse_group)
    @month_id  = (params[:month] || (@selected_group.months_to_analyze)[0][0]).to_i
    
    case 
    when (@user.director? and @selected_group.manager.person?)
       @developers = [@selected_group.manager] + @selected_group.developers
    else
       @developers = @selected_group.developers
    end
 

    render :layout => false 
  end

  def user_data_for_range
    require_manager
    @selected_group = (Group.find_by_id(params[:group]) || current_user.worse_group)
    @dev = @selected_group.developers.find(:first, :conditions => {:id => params[:user].to_i}) || @selected_group.manager
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

  def group_trend_for_range
    require_manager
    @selected_group = (Group.find_by_id(params[:group]) || current_user.worse_group)
    @focus_user = User.find_by_id(params[:focususer])
    @week_id  = params[:week].to_i
    @month_id = params[:month].to_i
    @data = Array.new
    
    if params[:week]
      (@week_id-15..@week_id).each do |week|
          @data << wj_trend(@selected_group, week, @focus_user.to_a)
        end
    else    
      (@month_id-6..@month_id).each do |month|
          @data << mj_trend(@selected_group, month, @focus_user.to_a)
        end
    end
    
    @jresult = JSON.generate(["data" => @data])

    render :layout => false, :action  => 'user_data_for_range'
  end

  private

  def pj(day,user)
    if lwd = user.logged_working_days.select{|d| d.wday == day}[0]
      return [[lwd.duration,lwd.homework_duration], {"label" => lwd.label, "bar_label" => lwd.bar_label},
      {"flag" => lwd.color},{"check_in" => lwd.check_in.strftime("%H:%M"),"check_out" =>lwd.check_out.strftime("%H:%M")}]
    else
      return ['', {"label" => @template.day_value(day),  "bar_label" => ''}, {"flag" => "White"},
      {"check_in" => '',"check_out" => ''}]
    end
  end

  def gj(day,group,developers=[])
    @stack = Array.new
    
    @stack << group.day_average(day)

    developers.each do |dev|
      lwd = dev.logged_working_days.select{|d| d.wday == day}[0]
      @stack << ((lwd.duration if lwd) || 0)
    end
    
  
    [@stack,  {"label" => @template.day_value(day)}]
  end
  
  def wj_trend(group,week = Date.today.cweek,developers=[])
    @stack = Array.new
    @stack << group.week_average(week)
    
    developers.each do |dev|
      @stack << dev.week_average(week)
    end
  
    [@stack,  {"label" => @template.week_value(week)}]
  end
  
  def mj_trend(group,month = Date.today.month,developers=[])
    @stack = Array.new
    @stack << group.month_average(month)
    
    developers.each do |dev|
      @stack << dev.month_average(month)
    end
  
    [@stack,  {"label" => @template.month_value(month)}]
  end

end


