class DashboardController < ApplicationController

  def index
    require_user
    @user = current_user
  end
  
  def daily_bars
@data = '{
  "message": "Hi There",
  "data": [
		  [15, {"label": ""}, {"flag": "Grey"}],
      	  [10, {"label": ""}, {"flag": "Red"}],
		  [10, {"label": ""}, {"flag": "White"}]
         ]
}'
   render :layout => false
  end
  
  def index2
    require_user
    @user = current_user   
  end
end


