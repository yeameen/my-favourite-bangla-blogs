class Blog < ActiveRecord::Base
  require 'rss/2.0'
  require 'hpricot'
  
  has_many :users_blogs
  has_many :users, :through => :user_blogs
  belongs_to :site
  has_many :posts

  def self.fetch_posts
    blogs = find(:all, :conditions => {:id => 9})

    blogs.each do |blog|
      feed_url = "#{blog.url}/#{blog.site.feed_suffix}"
      puts "fetching #{feed_url}\n"
      open(feed_url) do |http|
        begin
          response = http.read
          result = RSS::Parser.parse(response, false)
          result.items.each do |item|
            post = Post.find(:first, :conditions => {:url => item.link})
            if post.nil?
              post = Post.new(
                    :title => item.title,
                    :url => item.link,
                    :blog_id => blog.id,
                    :content => item.description,
                    :posted_at => DateTime.parse(item.pubDate.to_s).to_s(:db)
                  )
              puts ("Adding new post - #{post.inspect}")
              post.save

              #TODO: add post to users_posts table
              update_users_posts(post)
            end
          end
        rescue
          puts("\nError - Blog - #{blog.id}, blog url - #{blog.url} - #{$!}\n")
        end
      end
    end

    # get all posts and update comment_count
    # update_posts()
  end

  # update posts
  # now updates only comment count
  def self.update_posts()
    posts = Post.find(:all, :conditions => {:blog_id => 9})
    posts.each do |post|
      xpath_num_comment = post.blog.site.xpath_num_comment
      xpath_rating = post.blog.site.xpath_rating

      # get number of comments
      puts "Fetching post #{post.id} - #{post.title}"
      doc = Hpricot.parse(open(post.url))
      bn_number = (doc/"#{xpath_num_comment}").to_s.split[0]
      en_number = translate_number_from_bangla(bn_number)
      puts "Number of comments: #{bn_number} - #{en_number}"
      post.num_comments = en_number

      # get ratings
      # get positive rating
      bn_number_positive = (doc/"#{xpath_rating}").to_s.strip.split[1]
      en_number_positive = translate_number_from_bangla(bn_number_positive)
      post.rating_positive = en_number_positive

      # get negative rating
      bn_number_negative = (doc/"#{xpath_rating}").to_s.strip.split[5]
      en_number_negative = translate_number_from_bangla(bn_number_negative)
      post.rating_negative = en_number_negative
      puts "Rating: #{bn_number_positive}/#{bn_number_negative} - #{en_number_positive}/#{en_number_negative}"

      unless post.save
        puts("Error updating post")
      end
    end
    return nil
  end

  private
  def self.translate_number_from_bangla(p_bn_number)
    en_number = 0
    length = p_bn_number.length
    for i in 1..length/3 do
      en_number *= 10
      cur_digit = p_bn_number[3*i-1].to_i - 166
      en_number += cur_digit
    end
    return en_number
  end

  private
  def self.update_users_posts(p_post)
    users = UsersBlog.find(:all, :conditions => {:blog_id => p_post.blog_id})
    users.each do |user|
      user_post = UsersPost.new(
        :user_id => user.user_id,
        :post_id => p_post.id,
        :num_old_comments => 0,
        :is_read => 0,
        :status => 0
      )
      unless user_post.save
        puts ("Couldn't save post #{post.id} for user #{user.user_id}")
      end
    end
  end
end
