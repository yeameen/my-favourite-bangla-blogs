# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '3de2b0f5d106e42235acd13b1a3e53b7'

  ActiveScaffold.set_defaults do |config|
    config.ignore_columns.add [:created_at, :updated_at]
  end

  protected
  def authorize
    unless session[:user]
      flash[:notice] = "Please log in"
      # save the URL the user requested so we can hop back to it
      # after login
      session[:jumpto] = request.parameters
      redirect_to(:controller => "my", :action => "login")
    end
  end

  include SecurityHelper
end
