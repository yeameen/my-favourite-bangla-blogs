require File.join(File.dirname(__FILE__), '../../lib/presenter/presenter.rb')

class UserBlog < Presenter
  def_delegators :user_account, :name, :name=
  def_delegators :address, :line_1, :line_2, :city, :state, :zip_code
                           :line_1=, :line_2=, :city=, :state=, :zip_code=
  def_delegators :user_credentials, :username, :password, :username=, :password=

  def user_account
    @user_account ||= UserAccount.new
  end

  def address
    @address ||= Address.new
  end

  def user_credentials
    @credentials ||= UserCredential.new
  end

  def save
    user_account.save && address.save && user_credentials.save
  end
end