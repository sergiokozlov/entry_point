class DashboardController < ApplicationController

  def index
    require_user
    @user = current_user
    @length = 10
    @lag = 1    
  end
  
  def daily_bar_forward
    @lag = 2
    respond_to do |format|
        format.js
    end
  end
  
  def index2
    require_user
    @user = current_user   
  end
end


