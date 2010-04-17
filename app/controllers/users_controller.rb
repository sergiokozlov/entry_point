class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.login = (params[:user][:email])
    @user[:type], @user[:reports_to] = user_type_manager(@user.login)

      if @user.save  
        flash[:notice] = "Registration successful."  
        redirect_to :controller => 'records', :action => 'show' 
      else  
        render :action => 'new'  
      end
  
  end

  def edit
    @user = current_user
  end

end
