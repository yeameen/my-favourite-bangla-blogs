class MyController < ApplicationController

  def index
    redirect_to :action => "login"
  end
  
  def login

  end

  def mock_login
    begin
      user = User.find(params[:id])
    rescue
      render :text => "Wrong id" and return
    end
    init_session(user)

    jumpto =  { :controller => "blog", :action => "list" }
    session[:jumpto] = nil
    redirect_to(jumpto) and return
  end

  def login_check
    if !session[:user_id].nil?
      redirect_to root_url and return
    end
    if using_open_id?
      authenticate
    else
      set_flash_message(Constant::Flash::MESSAGE_REQUIRE_VALID_OPENID, Constant::Flash::TYPE_WARNING)
      redirect_to :action => "index" and return
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to :action => "index"
  end

  protected
  def authenticate(identity_url = "")

    authenticate_with_open_id(
        params[:openid_url], :required => [:nickname, :email]) do
    |result, identity_url, registration|

      if result.successful?

        openid_user = {
          :identity_url => identity_url,
          :name => registration["nickname"],
          :email => registration["email"]
        }

        # check if user is already in the database. if not, create one
        # TODO: no further openid login
#        db_user = User.find_or_create_by_identity_url(openid_user)
        db_user = User.find_by_identity_url(openid_user[:identity_url])
        if db_user.nil?
          set_flash_message(Constant::Flash::MESSAGE_OPENID_SIGNUP_STOPPED, Constant::Flash::TYPE_WARNING)
          redirect_to login_url
          return
        end

        init_session(db_user)

        jumpto = session[:jumpto] || { :controller => "blog", :action => "list" }
        session[:jumpto] = nil
        redirect_to(jumpto) and return
      else
        set_flash_message(result.message, Constant::Flash::TYPE_ERROR)
        redirect_to :action => "index"
      end
    end
  end

  def root_url
    openid_url
  end
end