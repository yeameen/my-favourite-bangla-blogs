class UsersPost < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user
  belongs_to :post

  def comment
    user_blog = UsersBlog.find(:first, :conditions => {:user_id => self.user_id, :blog_id => self.post.blog_id})
    return user_blog.comment unless user_blog.nil?
  end
end
