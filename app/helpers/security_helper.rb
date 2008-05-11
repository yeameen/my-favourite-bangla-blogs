module SecurityHelper
  protected
  def active_user()
    return session[:user]
  end
end