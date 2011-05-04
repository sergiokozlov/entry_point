class RecordsController < ApplicationController

  #Post entry record

  def new 
	@user = current_user
	require_user
	@record = Record.new
  end


  #TODO: Think about CallBacks, Think about find_or_create_by_name

  def create
    @user = current_user
    
    @click_date_string = params[:record][:check_date] + ' ' + params[:record][:check_time] 
    #render :action => 'show'

    @record =  @user.records.build({:click_date_string => @click_date_string, :submit_type => 'manual'})
       if @record.save

          @record.process
          @record.working_day.recalculate 
          flash[:checkin_notice] = "Thank you! Your record has been added."
          redirect_to :controller => 'dashboard', :action => 'index', :week => @record.click_date.cweek
       else
          flash[:checkin_error] = @record.errors[:base]
          redirect_to :controller => 'dashboard', :action => 'index'
        end

  end 
  
  
  def show
    require_user
    @user = current_user
    
    # No recalculation required - just pass @var with current Duration
    if @working_today = @user.working_days.find(:first, :conditions => {:wday => Time.now.to_date})
         @distance_walked = (Time.now.to_i - @working_today.check_in.to_i).floor/60
    end

    @logged_records =  @user.records.find(:all, :order => 'click_date')
    @logged_working_days = @user.logged_working_days
       
  end
 
  def destroy
    begin
      if params[:record]
        @record = Record.find(params[:record].first)
        @date = @record.click_date
        params[:record].each { |r| Record.destroy(r) }
        @wd = @record.working_day
      end
    
      if params[:homework]
        @homework = Homework.find(params[:homework].first)
        @date = @homework.check_in
        params[:homework].each { |h| Homework.destroy(h) }
        @wd = @record.working_day
      end
      @wd.recalculate!
      redirect_to :controller => 'dashboard', :action => 'index',:week => @date.to_date.cweek
    rescue
      flash[:correction_error] = 'Something went wrong - please try again'
      redirect_to :controller => 'dashboard', :action => 'index'
    end
   
    
    #render :text => "#{params[:record]"
  end

   
end
