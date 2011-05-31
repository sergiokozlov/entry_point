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
 
  def set_lunch_time
    @user = current_user
    @errors = []

    #validate lunch_update_from_date_parameter
    begin
        @from_date =  DateTime.strptime(params[:lunch_update_from_date],'%Y-%m-%d')

        if (Time.now - @from_date)/3600/24 > ACFG['submit_window_left']
            @errors << "You cannot update Records earlier than 45 days from now"
        end

    rescue ArgumentError
        @errors << "Invalid Date Format"
    end
    
    if @user.update_attributes(params[:user]) and @errors.empty?
        @new_lunch_time = params[:user][:lunch_time_setting]
        flash[:settings_notice] = "Lunch Time was successfully updated"

        @user.working_days.select {|wd| wd.wday >= @from_date}.each do |wd|
          wd.lunch_time = @new_lunch_time
          wd.save!
        end

        redirect_back
    else
        flash[:settings_error] =  @errors.map {|e| e + ' <br/>'} << @user.errors.on(:lunch_time_setting).to_s
        redirect_back
    end 

  end

end
