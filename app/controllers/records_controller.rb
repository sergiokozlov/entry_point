class RecordsController < ApplicationController
  #Post entry record
  def create
    @user = current_user
    @user.records.create(params[:record])
   
    flash[:notice] = "Thanks #{@user.login}- we will check this record"
    redirect_to :action => 'show'
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
