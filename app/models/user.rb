require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :users_blogs
  has_many :blogs,
    :through => :users_blogs,
    :select => "blogs.*, users_blogs.comment",
    :order => "users_blogs.created_at DESC"

  has_many :users_posts
  has_many :posts, :through => :users_posts,
    :select => "posts.*, users_posts.is_read"

  has_many :taggings
  has_many :tags, :through => :taggings, :select => "DISTINCT tags.*"

  has_many :blog_recommendations

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
#  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  before_create :make_activation_code 

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation


  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def user_id
    return id()
  end

  def self.send_update_notification
    users = User.all
    users.each do |user|
      if user.email_notification && !user.email.nil? && user.email != ''
        user_new_posts = user.users_posts.find(:all,
                                                :conditions => ["is_read = 0 AND created_at > ?", -1.days.from_now],
                                                :order => "created_at DESC",
                                                :limit => 15)

        user_updated_posts = user.users_posts.find(:all,
                                                    :conditions => ["is_read = 1 AND created_at > ?", -30.days.from_now],
                                                    :order => "created_at DESC",
                                                    :limit => 15)
        if !user_new_posts.empty? && !user_updated_posts.empty?
          UserMailer.deliver_update_notification(user, user_new_posts, user_updated_posts)
        end
      end
    end
  end

  protected
  def make_activation_code
    self.activation_code = self.class.make_token
  end
end
