class Blog < ActiveRecord::Base
  require 'rss/2.0'
  require 'hpricot'
  
  has_many :users_blogs
  has_many :users, :through => :user_blogs
  belongs_to :site
  has_many :posts

  def self.fetch_posts
    blogs = find(:all)

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
                    :url => item.link,
                    :blog_id => blog.id,
                    :content => item.description,
                    :posted_at => DateTime.parse(item.pubDate.to_s).to_s(:db)
                  )
              post.save
            end
          end
        rescue
          puts("\nError - Blog - #{blog.id}, blog url - #{blog.url}\n")
        end
      end
    end

    # get all posts and update comment_count
    update_posts()
  end

  # update posts
  # now updates only comment count
  def self.update_posts()
    posts = Post.find(:all, :conditions => {:blog_id => 9})
    posts.each do |post|
      xpath_num_comment = post.blog.site.xpath_num_comment
#      puts "#{post.blog.site.xpath_num_comment}\n"
      doc = Hpricot.parse(open(post.url))
      bn_number = (doc/"#{xpath_num_comment}").to_s.split[0]
      print bn_number + " "
      en_number = translate_number_from_bangla(bn_number)
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
      print cur_digit
      en_number += cur_digit
    end
    puts " comments"
    return en_number
  end
end
