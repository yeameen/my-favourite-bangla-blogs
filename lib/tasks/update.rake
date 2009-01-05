namespace :update do
  desc "Update blogs"
  task :blogs => :environment do
    Blog.fetch_posts
  end

  desc "Update posts"
  task :posts => :blogs do
    Blog.update_posts
  end

  desc "Send update"
  task :notification => :environment do
    User.send_update_notification
  end

  desc "update all hash keys"
  task :keys => :environment do
    users_posts = UsersPost.all
    users_posts.each do |user_post|
      user_post.add_key if user_post.key.nil? || user_post.key.to_s == ""
    end
  end
end