class UserSessionsController < ApplicationController
  def new
    unless current_user
      @user_session = UserSession.new
    else
      if current_user.director?  
        redirect_to :controller => 'dashboard', :action => 'overview'
      elsif current_user.manager?
        redirect_to :controller => 'dashboard', :action => 'manage'
      else
        redirect_to :controller => 'dashboard'
      end  
    end  
  end

  def create  
    @user_session = UserSession.new(params[:user_session])  
    if @user_session.save  
     flash[:notice] = "Successfully logged in."
     @director_url = url_for(:controller => 'dashboard', :action => 'overview', :only_path => false)
     @manager_url = url_for(:controller => 'dashboard', :action => 'manage', :only_path => false)
     @user_url = url_for(:controller => 'dashboard', :only_path => false)

      if current_user.manager?
          respond_to do |format|
            format.html { redirect_to :controller => 'dashboard', :action => 'manage'}
            format.js { render :js => "window.location.replace('#{@manager_url}')"}
          end
      elsif current_user.director?
        respond_to do |format|
          format.html { redirect_to :controller => 'dashboard', :action => 'overview'}
          format.js { render :js => "window.location.replace('#{@director_url}')"}
        end
      else
         respond_to do |format|
            format.html { redirect_to :controller => 'dashboard'}
            format.js { render :js => "window.location.replace('#{@user_url}')"}
          end
      end  
    else  
       respond_to do |format|
            format.html {  render :action => 'new'}
            format.js { render :text => "Bad" }
          end
   
   end  
  end
 
  def destroy
    @user_session = UserSession.find  
    @user_session.destroy  
    flash[:notice] = "Successfully logged out."  
    redirect_to root_path 
  end
end
