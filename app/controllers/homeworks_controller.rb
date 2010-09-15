class HomeworksController < ApplicationController

  def new
      require_user
      @homework = Homework.new
  end

   def create
    @user = current_user
    @homework = @user.homeworks.build(params[:homework])
       if @homework.valid?
          
          @homework.process
          redirect_to :action => 'show'
       else
          render :action => 'new'
       end
   end
    
  def show
    require_user
    @user = current_user

    @logged_homeworks =  @user.homeworks.find(:all, :order => 'check_in')
  end


end
