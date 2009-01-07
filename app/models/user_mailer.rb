class UserMailer < ActionMailer::Base
  SITE_NAME = 'onushoron.morphexchange.com'
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://#{SITE_NAME}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{SITE_NAME}/"
  end

  def update_notification(user, user_new_posts, user_updated_posts)
    max_count = 15
    setup_email(user)


    # Add unseen posts
    new_posts = user_new_posts #.inject([]){|all,temp| all << temp.post}

    # Add updated posts
    updated_posts = []
    count = 0
    user_updated_posts.each do |user_post|
      unless count > max_count
        post = user_post.post
        comment_diff = post.num_comments.to_i - user_post.num_old_comments.to_i
        if comment_diff > 0
          updated_posts << user_post
          count += 1
        end
      end
    end
    @subject += "Favourite Bangla blogs' daily update"
    @body[:new_posts] = new_posts
    @body[:updated_posts] = updated_posts
    @content_type = "text/html"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[#{SITE_NAME}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
