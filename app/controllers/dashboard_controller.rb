class DashboardController < ApplicationController
  helper ApplicationHelper # include all helpers, all the time
  before_filter :store_location, :only => [:index, :manage, :overview]

  def index
    require_user
    @user = current_user
    session[:week] = @week_id = (params[:week] || @user.logged_working_weeks.first[0]).to_i
    session[:year] = @year = (params[:year] || @user.logged_working_weeks.first[1]).to_i
    @last_load = Record.maximum('click_date', :conditions => {:submit_type => 'auto'})
    
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
      if session[:week] == 52
        session[:week] = 1
        session[:year] += 1
      else
        session[:week] += 1
      end
    elsif params[:id] == 'backward'
      if session[:week] == 1
        session[:week] = 52
        session[:year] -= 1
      else
        session[:week] -= 1
      end
    elsif params[:week] and params[:year]
      session[:week] = params[:week].to_i
      session[:year] = params[:year].to_i  
    end
        
    @week_id = (params[:week] || session[:week]).to_i
    @year = (params[:year] || session[:year]).to_i
    
    days_array(7,@template.week_last_day(@week_id, @year) - Date.today).each do |day|
      @data << pj(day,@user)
    end

    @jresult = JSON.generate(["data" => @data])

    render :layout => false
  end

  def my_manual_entries
    require_user
    @user = current_user
    @wd = WorkingDay.find(params[:id])

    render :layout => false
  end
  
  def get_session_week
    @a_result = @template.week_value(session[:week], session[:year])
    
    @first_week = current_user.logged_working_weeks.last
    @last_week = current_user.logged_working_weeks.first
    
    render :ajax_result, :layout => false
  end
  
  def team_data_by_week
    require_manager
    @user = current_user
    @selected_group = (Group.find_by_id(params[:group]) || @user.worse_group)
    @week_id  = (params[:week] || (@selected_group.weeks_to_analyze)[0][0]).to_i
    @year = (params[:year] || (@selected_group.weeks_to_analyze)[0][1]).to_i

    
    @group_average = @selected_group.week_average(@week_id, @year)
    
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
    @year = (params[:year] || (@selected_group.months_to_analyze)[0][1]).to_i
    
    @group_average = @selected_group.month_average(@month_id, @year)
    
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
    @year = params[:year].to_i
    @data = Array.new

    if @dev 
      days_array(7,@template.week_last_day(@week_id, @year) - Date.today).each do |day|
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
    @year = params[:year].to_i
    @data = Array.new
    
    # build week, year and month, year pairs
    if params[:week]
      @template.recent_weeks(@week_id, @year, 15).each do |week, year|
          @data << wj_trend(@selected_group, week, year, @focus_user.to_a)
        end
    else    
      @template.recent_months(@month_id, @year, 6).each do |month, year|
          @data << mj_trend(@selected_group, month, year, @focus_user.to_a)
        end
    end
    
    @jresult = JSON.generate(["data" => @data])

    render :layout => false, :action  => 'user_data_for_range'
  end

  private

  def pj(day,user)
    if lwd = user.working_days.select{|d| d.wday == day}[0]
      return [[lwd.duration,lwd.homework_duration], {"label" => lwd.label, "bar_label" => lwd.bar_label, "wd" => lwd.has_manual_entries, "lunch_time" => lwd.real_lunch_time}, {"flag" => lwd.color},{"check_in" => lwd.check_in.strftime("%H:%M"),"check_out" =>lwd.check_out.strftime("%H:%M")}]
    else
      return ['', {"label" => @template.day_value(day),  "bar_label" => ''}, {"flag" => "White"},
      {"check_in" => '',"check_out" => ''}]
    end
  end

  def gj(day,group,developers=[])
    @stack = Array.new
    
    @stack << group.day_average(day)

    developers.each do |dev|
      lwd = dev.working_days.select{|d| d.wday == day}[0]
      @stack << ((lwd.duration if lwd) || 0)
    end
    
  
    [@stack,  {"label" => @template.day_value(day)}]
  end
  
  def wj_trend(group, week = Date.today.cweek, year = Date.today.year, developers=[])
    @stack = Array.new
    @stack << group.week_average(week, year)
    
    developers.each do |dev|
      @stack << dev.week_average(week, year)
    end
  
    [@stack,  {"label" => @template.week_value(week, year)}]
  end
  
  def mj_trend(group,month = Date.today.month, year = Date.today.year, developers=[])
    @stack = Array.new
    @stack << group.month_average(month, year)
    
    developers.each do |dev|
      @stack << dev.month_average(month, year)
    end
  
    [@stack,  {"label" => @template.month_value(month)}]
  end

end


