class User < ActiveRecord::Base
  #acts_as_tagger
  
  has_many :users_blogs
  has_many :blogs, :through => :users_blogs

  has_many :users_posts
  has_many :posts, :through => :users_posts

  has_many :taggings
  has_many :tags, :through => :taggings, :select => "DISTINCT tags.*"

  has_many :blog_recommendations
end
