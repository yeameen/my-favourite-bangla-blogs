class Post < ActiveRecord::Base
  acts_as_taggable

  belongs_to :blog
  has_many :users_posts
end
