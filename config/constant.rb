class Constant
  module Flash
    MESSAGE_REQUIRE_LOGIN = "Please log in"
    MESSAGE_WRONG_LOGIN = "wrong username or password"
    MESSAGE_SUCCESSFUL_LOGIN = "Logged in successfully"
    MESSAGE_SUCCESSFUL_LOGOUT = "you have logged out successfully"

    # OpenID messages
    MESSAGE_REQUIRE_VALID_OPENID = "You must provide an OpenID URL"
    MESSAGE_OPENID_SIGNUP_STOPPED = "No further OpenID signup allowed"

    # Email verification messages
    MESSAGE_VERIFY_EMAIL = "Thanks for signing up!  Please check your email for activation code"
    MESSAGE_EMAIL_VERIFIED = "Signup complete! Please sign in to continue"
    MESSAGE_MISSING_ACTIVATION = "Signup complete! Please sign in to continue"
    MESSAGE_WRONG_ACTIVATION = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in"
    MESSAGE_ERROR_CREATING_ACCOUNT = "We couldn't set up that account, sorry.  Please try again, or contact the admin"

    MESSAGE_MISSING_PARAMETER = "Parameter missing"
    MESSAGE_SETTINGS_UPDATED = "Settings updated successfully"

    MESSAGE_BLOG_ERROR = "Couldn't save blog"

    TYPE_NOTIFICATION = "notification"
    TYPE_WARNING = "warning"
    TYPE_ERROR = "error"
  end
end