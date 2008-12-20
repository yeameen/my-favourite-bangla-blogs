class User < ActiveRecord::Base
  #acts_as_tagger
  
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

  def user_id
    return id()
  end
end
