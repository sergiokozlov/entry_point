class RecordsController < ApplicationController

  #Post entry record

  def new
      require_user
       @record = Record.new
  end


  def create
    @user = current_user
    @record =  @user.records.build(params[:record])
  if @record.save
    flash[:notice] = "Thanks #{@user.login}- we will check this record"
    redirect_to :action => 'show'
  else
    render :action => 'new'
  end
 
  end 

  
  
  def show
   if  @user = current_user
        #@logged_records = Record.find(:all, :conditions => { :login => @user.login})
        @logged_records =  @user.records
       
   else
      @logged_records = Record.find(:all) 
   end
  end
  
  

   
end
