class DashboardController < ApplicationController

  def index
    require_user
    @user = current_user
    
  end
end
