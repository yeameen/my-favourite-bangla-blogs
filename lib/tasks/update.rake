namespace :update do
  desc "Update blogs"
  task :blogs => :environment do
    Blog.fetch_posts
  end

  desc "Update posts"
  task :posts => :blogs do
    Blog.update_posts
  end
end