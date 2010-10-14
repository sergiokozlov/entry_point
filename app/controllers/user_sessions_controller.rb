class UserSessionsController < ApplicationController
  def new
    unless current_user
      @user_session = UserSession.new
    else
      if current_user.manager?  
        redirect_to :controller => 'dashboard', :action => 'manage'
      else
        redirect_to :controller => 'dashboard'
      end  
    end  
  end

  def create  
    @user_session = UserSession.new(params[:user_session])  
    if @user_session.save  
     #flash[:notice] = "Successfully logged in."
      if current_user.manager?  
        redirect_to :controller => 'dashboard', :action => 'manage'
      else
        redirect_to :controller => 'dashboard'
      end  
    else  
     render :action => 'new'  
   end  
  end
 
  def destroy
    @user_session = UserSession.find  
    @user_session.destroy  
    flash[:notice] = "Successfully logged out."  
    redirect_to root_path 
  end
end
