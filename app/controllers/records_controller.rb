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
         if @record.first?
            @processed_day = @record.create_working_day(:login => @user.login,:wday => @record.click_date.strftime("%m/%d/%Y"))
            @record.working_day = @processed_day
            @record.save
         else
            @record.working_day =@record.tagged_working_day
            @record.save
          @record.working_day.recalculate   
         end

          flash[:notice] = "Thanks #{@user.login}- we will check this record"
          redirect_to :action => 'show'
       else
          render :action => 'new'
        end
   
  end 

  
  
  def show
    require_user
    @user = current_user
    
    if @working_today = @user.working_days.find(:first, :conditions => {:wday => Time.now.to_date})
         @working_today.recalculate('today')
    end

    @logged_records =  @user.records
    @logged_working_days = @user.working_days
       
  end
  
  

   
end