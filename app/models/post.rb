class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :users_posts
end
