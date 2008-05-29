require File.join(File.dirname(__FILE__), '../../lib/recommendation/recommendation.rb')

class BlogRecommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  
  public
  def self.update_recommendations
    puts "Updating recommendation"
    user_preferences = get_user_preferences()
    user_preferences.each do |user_id, preferences|
      puts("Computing recommendation for user - #{user_id}")
#      puts("NUmber of recommended items for user - #{user_id}: #{Recommendation::get_recommendations(user_preferences, user_id).inspect}")

      recommended_blogs = Recommendation::get_recommendations(user_preferences, user_id).inject([]) do |temp, cur|
        temp + [cur[1]]
      end
      puts "Recommended blogs - #{recommended_blogs.inspect}"

      recommended_blogs.each do |blog_id|
        unless find(:first, :conditions => {:user_id => user_id, :blog_id => blog_id})
          create(:user_id => user_id, :blog_id => blog_id, :is_new => true, :is_rejected => false)
        end
      end
    end
  end

  private
  def self.get_user_preferences()
    user_preferences = {}
    blogs_hash = {}
    users = User.find(:all)
    for user in users
      # consider users who has at least 3 bookmarks
#      next user.blogs.count < 3

      # 1.count positive recommendations
      positive_user_ratings = user.blogs.inject({}){|temp, cur| temp.merge({cur.id => 1.0})}
      puts "positive user rating - #{positive_user_ratings.inspect}"

      # 2.count negative recommendations (rejected recommendations)
      rejected_recommendations = self.find(:all, :conditions => {:user_id => user.id, :is_rejected => 1})
      negative_user_ratings = rejected_recommendations.inject({}) {|temp, cur| temp.merge({cur.blog_id => -0.5})}
      puts "negative user rating - #{negative_user_ratings}"

      # *.count all unanswered; those are already listed, so safe to remove
      
      # 3.now merge
      user_ratings = negative_user_ratings.merge(positive_user_ratings)
      user_preferences[user.id] = user_ratings
#      puts "total user preferences - #{user_preferences.inspect}"
      blogs_hash.merge!(user_ratings)
    end

    puts "total user preferences - #{user_preferences.inspect}"
    # assign unrated blogs as 0 rating
    user_preferences.each do |user, ratings|
      blogs_hash.each do |blog_id, rating|
        user_preferences[user][blog_id] = 0.0 unless ratings.has_key?(blog_id)
      end
    end

    return user_preferences
  end
end
