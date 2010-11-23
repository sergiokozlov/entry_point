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
    if @user.valid_password? (params[:old_password])
    
      if @user.update_attributes(params[:user])
          flash[:settings_notice] = "Password was successfully updated"
          redirect_back
      else
          flash[:settings_error] = "Password doesn't match with it's confirmation"
          redirect_back
      end
    else
        flash[:settings_error] = "Old Password is incorrect"
        redirect_back
    end  
  end

end
