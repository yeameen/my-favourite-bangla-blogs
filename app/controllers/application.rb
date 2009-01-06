# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'will_paginate'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '3de2b0f5d106e42235acd13b1a3e53b7'

  include SecurityHelper
  include AuthenticatedSystem

  protected
  def authorize
    unless logged_in?
      set_flash_message(Constant::Flash::MESSAGE_REQUIRE_LOGIN, Constant::Flash::TYPE_NOTIFICATION)
      # save the URL the user requested so we can hop back to it
      # after login
      session[:jumpto] = request.parameters
      redirect_to login_url
    end
  end

  protected
  def set_flash_message(p_message, p_type = Constant::Flash::TYPE_NOTIFICATION)
    flash[:message] = p_message
    flash[:type] = p_type
  end
end
