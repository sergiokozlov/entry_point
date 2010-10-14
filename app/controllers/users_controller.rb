class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.login = (params[:user][:email])
    harr = users_hierarchy
    @user[:type], @user[:reports_to] = user_type_manager(@user.login,harr)

      if @user.save  
        flash[:notice] = "Registration successful."  
        redirect_to :controller => 'dashboard' 
      else  
        render :action => 'new'  
      end
  
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes( params[:user] || params[:manager]) #TODO: understand how to pass user here
      flash[:notice] = "Account updated!"
      redirect_to :controller => 'dashboard'
    else
      render :action => :edit
    end
  end

end
