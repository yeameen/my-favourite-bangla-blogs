class UsersPost < ActiveRecord::Base
  #acts_as_taggable
  after_create :add_key
  
  belongs_to :user
  belongs_to :post

  def comment
    user_blog = UsersBlog.find(:first, :conditions => {:user_id => self.user_id, :blog_id => self.post.blog_id})
    return user_blog.comment unless user_blog.nil?
  end

#  private
  def add_key
    temp_key = generate_key(id())
    while UsersPost.find_by_key(temp_key)
      temp_key = generate_key(id())
    end
    update_attribute(:key, temp_key)
    save()
  end

  private
  def generate_key(salt)
    require 'digest/md5'
    md5 = Digest::MD5::new
    now = Time::now
    md5.update(now.to_s)
    md5.update(String(now.usec))
    md5.update(String(rand(0)))
    md5.update(String($$))
    md5.update(salt.to_s)
    md5.hexdigest
  end
end
