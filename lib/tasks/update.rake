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
end