class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
#  include AuthenticatedSystem
  layout "template"
  

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      set_flash_message(Constant::Flash::MESSAGE_VERIFY_EMAIL)
      redirect_back_or_default('/')
    else
      set_flash_message(Constant::Flash::MESSAGE_ERROR_CREATING_ACCOUNT, Constant::Flash::TYPE_ERROR)
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      set_flash_message(Constant::Flash::MESSAGE_EMAIL_VERIFIED)
      redirect_to '/login'
    when params[:activation_code].blank?
      set_flash_message(Constant::Flash::MESSAGE_MISSING_ACTIVATION, Constant::Flash::TYPE_WARNING)
      redirect_back_or_default('/')
    else
      set_flash_message(Constant::Flash::MESSAGE_WRONG_ACTIVATION, Constant::Flash::TYPE_WARNING)
      redirect_back_or_default('/')
    end
  end
end
