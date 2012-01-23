class HomeworksController < ApplicationController

  def new
      @user = current_user
      require_user
      @homework = Homework.new
  end

   def create
    @user = current_user
    @check_in_string = params[:homework][:check_date] + ' ' + params[:homework][:check_in_time]
    @check_out_string = params[:homework][:check_date] + ' ' + params[:homework][:check_out_time]  

    @homework = @user.homeworks.build({:check_in_string => @check_in_string, :check_out_string => @check_out_string})
       if @homework.valid?
          
          @homework.process
          flash[:checkin_notice] = "Thanks you we will check this homework record"
          redirect_to :controller => 'dashboard',:action => 'index', :week => @homework.check_in.cweek, :year => @homework.check_in.year
       else
          flash[:checkin_error] = @homework.errors[:base].map {|e| e + ' <br/>'}
          redirect_to :controller => 'dashboard', :action => 'index'
       end
   end
    
  def show
    require_user
    @user = current_user

    @logged_homeworks =  @user.homeworks.find(:all, :order => 'check_in')
  end


end
