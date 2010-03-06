class RecordsController < ApplicationController

  #Post entry record

  def new
      require_user
       @record = Record.new
  end


  #TODO: Think about CallBacks, Think about find_or_create_by_name

  def create
    @user = current_user
    @record =  @user.records.build(params[:record])
       if @record.save

          @record.process
          @record.working_day.recalculate 
          flash[:notice] = "Thanks #{@user.login}- we will check this record"
          redirect_to :action => 'show'
       else
          render :action => 'new'
        end
   
  end 
  
  
  def show
    require_user
    @user = current_user
    
    # No recalculation required - just pass @var with current Duration
    if @working_today = @user.working_days.find(:first, :conditions => {:wday => Time.now.to_date})
         @distance_walked = (Time.now.to_i - @working_day.check_in.to_i).floor/60
    end

    @logged_records =  @user.records.find(:all, :order => 'click_date')
    #@logged_records = Record.find(:all)
    @logged_working_days = @user.working_days.find(:all, :order => 'wday')
       
  end
 
  

   
end
