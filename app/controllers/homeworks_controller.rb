class HomeworksController < ApplicationController

  def new
      require_user
      @homework = Homework.new
  end

   def create
    @user = current_user
    @homework =  Homework.new(params[:homework])
       if @record.save

          redirect_to :action => 'show'
       else
          render :action => 'new'
       end
   end


end
