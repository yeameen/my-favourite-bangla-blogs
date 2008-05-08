class User < ActiveRecord::Base
  has_many :users_blogs
  has_many :blogs, :through => :users_blogs
end
