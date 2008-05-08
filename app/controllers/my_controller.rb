require 'ostruct'

class MyController < ApplicationController
#  include OpenIdAuthentication

  def index
    redirect_to :action => "login"
  end
  
  def login

  end

  def login_check
    if !session[:user].nil?
      redirect_to :controller => "blog", :action => "list" and return
    end
    if using_open_id?
      authenticate
    else
      flash[:error] = "You must provide an OpenID URL"
      redirect_to :action => "index" and return
    end
  end

  def logout
    session[:user] = nil
    redirect_to :action => "index"
  end

  protected
  def authenticate(identity_url = "")
    authenticate_with_open_id(
        params[:openid_url], :required => [:nickname, :email]) do
    |result, identity_url, registration|

      if result.successful?
        openid_user = OpenStruct.new
        openid_user.identity_url = identity_url
        openid_user.nickname = registration["nickname"]
        openid_user.email = registration["email"]


        # check if user is already in the database. if not, create one
        db_user = create_user_if_not_exists(openid_user)
        openid_user.user_id = db_user.id

        session[:user] = openid_user

        jumpto = session[:jumpto] || { :controller => "blog", :action => "list" }
        session[:jumpto] = nil
        redirect_to(jumpto) and return
      else
        flash[:error] = result.message
        redirect_to :action => "index"
      end
    end
  end

  def root_url
    openid_url
  end

  private
  def create_user_if_not_exists(p_openid_user)
    db_user = User.find(:first, :conditions => {:identity_url => p_openid_user.identity_url})
    if db_user.nil?
      db_user = User.new(:name => p_openid_user.nickname,
                        :email => p_openid_user.email,
                        :identity_url => p_openid_user.identity_url)
      db_user.save
    end
    return db_user
  end
end