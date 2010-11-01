# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  #
  helper_method :current_user, :days_array, :users_hierarchy 

  HRH_DIR = File.dirname(__FILE__) + "/../../public/hierarchy" 
  
  private  
  def current_user_session  
    return @current_user_session if defined?(@current_user_session)  
    @current_user_session = UserSession.find  
  end  
  
  def current_user  
   @current_user = current_user_session && current_user_session.record  
  end
 
  def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
  end

  def require_manager
      require_user
      unless current_user.manager?
        flash[:notice] = "Only Managers can access this page"
        redirect_to :controller => 'dashboard'
      end
  end
  
  def require_director
      require_user
      unless current_user.director?
        flash[:notice] = "Only Directors can access this page"
        redirect_to :controller => 'dashboard'
      end
  end

  def store_location
      session[:return_to] = request.request_uri
  end
  
 # charts related
  def days_array(length,lag=0)
    a = Array.new
    d = Date.today
    (-length+1..0).each {|i| a << d + i + lag}
    return a
  end

 # users identification
  def users_hierarchy
    File.open(HRH_DIR+"/enkata.yml") do |file|
     return  arr = YAML::load(file)
    end
  end
 
end
