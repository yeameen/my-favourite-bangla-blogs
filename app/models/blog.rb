class Blog < ActiveRecord::Base
  require 'rss/2.0'
  require 'hpricot'
#  require 'open-uri'
#  require 'nokogiri'

  #TODO: some codes are commented out to meet mor.ph requirement

  has_many :users_blogs
  has_many :users, :through => :user_blogs
  belongs_to :site
  has_many :posts

  has_many :blog_recommendations

  def feed_url
    return "#{url}/#{site.feed_suffix}"
  end

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
                    :title => item.title,
                    :url => item.link,
                    :blog_id => blog.id,
                    :content => item.description,
                    :posted_at => DateTime.parse(item.pubDate.to_s).to_s(:db)
                  )
              puts ("Adding new post - #{post.inspect}")
              post.save

              # add post to users_posts table, if the post is posted withing last 24 hours
              if post.posted_at > -1.days.from_now
                update_users_posts(post)
              end
            end
          end
        rescue
          puts("\nError - Blog - #{blog.id}, blog url - #{blog.url} - #{$!}\n")
        end
      end
    end
  end

  # update posts
  # now updates only comment count
  def self.update_posts()
    Hpricot.buffer_size = 1024144
    puts "\n\nUpdating posts--\n"
    posts = Post.find(:all, :conditions => ["posted_at > '#{-3.days.from_now.to_s(:db)}'"])
    posts.each do |post|
      begin
        site = post.blog.site
        xpath_num_comment = site.xpath_num_comment
        xpath_rating = site.xpath_rating
        xpath_num_reads = site.xpath_num_reads
        xpath_post = site.xpath_post                   

        # positions
        num_comment_position = site.num_comment_position
        num_read_position = site.num_read_position
        positive_rating_position = site.positive_rating_position
        negative_rating_position  = site.negative_rating_position

        # get number of comments
        logger.debug("Updating post #{post.id} - #{post.title}")

        doc = nil
#        begin
#          doc = Nokogiri::HTML(open(post.url))
#        rescue
          doc = Hpricot.parse(open(post.url))
#        end

        unless xpath_post.nil? && xpath_post != ''
          post.content = doc.search(xpath_post).inner_text
        end

        unless xpath_num_comment.nil? && xpath_num_comment != ''
          bn_number = doc.search(xpath_num_comment).inner_text.split[num_comment_position.to_i]
          en_number = translate_number_from_bangla(bn_number)
          puts "Number of comments: #{bn_number} - #{en_number}"
          post.num_comments = en_number
        end

        # get number of reads
        unless xpath_num_reads.nil? && xpath_num_reads != ''
          bn_number = doc.search(xpath_num_reads).inner_text.split[num_read_position.to_i]
          en_number = translate_number_from_bangla(bn_number)
          puts "Number of reads: #{bn_number} - #{en_number}"
          post.num_reads = en_number
        end

        # get ratings
        unless xpath_rating.nil? && xpath_rating != ''
          # get positive rating
          bn_number_positive = doc.search(xpath_rating).inner_text.strip.split[positive_rating_position.to_i]
          en_number_positive = translate_number_from_bangla(bn_number_positive)
          post.rating_positive = en_number_positive

          # get negative rating
          bn_number_negative = doc.search(xpath_rating).inner_text.strip.split[negative_rating_position.to_i]
          en_number_negative = translate_number_from_bangla(bn_number_negative)
          post.rating_negative = en_number_negative
          puts "Rating: #{bn_number_positive}/#{bn_number_negative} - #{en_number_positive}/#{en_number_negative}"
        end

        unless post.save
          raise("Error updating post")
        end
      rescue
        puts("Error occured in fetching post - #{$!}")
      end
    end
    return nil
  end

  private
  def self.translate_number_from_bangla(p_bn_number)
    # if already in roman digits
    return p_bn_number.to_i if p_bn_number.to_i != 0

    en_number = 0
    length = p_bn_number.length
    for i in 1..length/3 do
      cur_digit = p_bn_number[3*i-1].to_i - 166
#      next if cur_digit > 9 || cur_digit < 0
      if p_bn_number[3*i-2].to_i == 167 && cur_digit >= 0 && cur_digit <= 9
        en_number *= 10
        en_number += cur_digit
      end
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
        puts("Couldn't save post #{post.id} for user #{user.user_id}")
      end
    end
  end
end
