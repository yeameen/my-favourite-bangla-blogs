module SecurityHelper

#  protected
#  def logged_in?()
#    return !session[:user_id].nil?
#  end

  protected
  def init_session(user)
    return unless user.is_a?(User)
    session[:user_id] = user.id
  end

  protected
  def active_user()
    return User.find(session[:user_id])
  end
end