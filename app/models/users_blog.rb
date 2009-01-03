class UsersBlog < ActiveRecord::Base
  require 'rss/2.0'

  belongs_to :user
  belongs_to :blog

  before_save :check_duplicate

  def url
    return Blog.find(self.blog_id).url unless blog_id.nil?
    return nil
  end

  def url=(p_url)
    site_id, formatted_url = format_url(p_url)
    if site_id.nil?
      raise "Illegal site"
    end

    blog = Blog.find(:first, :conditions => {:url => formatted_url, :site_id => site_id})
    begin
      if blog.nil?
        # blog doesn't exists. so, add the blog entry
        # fetch the rss feed to get the title
        blog_feed_url = "#{formatted_url}/#{Site.find(site_id).feed_suffix}"
        logger.debug("\bAdding new Blog - feed url - #{blog_feed_url}\n")
        rss = RSS::Parser.parse(open(blog_feed_url), false)
        blog_title = rss.channel.title

        # create the blog entry
        blog = Blog.new(:url => formatted_url, :site_id => site_id, :title => blog_title)
        unless blog.save
          raise "Couldn't save blog"
        end
      end
      self.blog_id = blog.id
    rescue
      logger.debug("Error creating new blog entry - #{$!}")
    end
  end

  private
  def check_duplicate
    if UsersBlog.find(:first, :conditions => {:user_id => self.user_id, :blog_id => self.blog_id})
      return false
    end
  end

  private
  def format_url(p_url)
    case p_url
    when /^(http\:\/\/)?(www\.)?somewhereinblog/
      blog_name = p_url.gsub(/http\:\/\/|www\.|somewhereinblog\.net\//, '').gsub(/^blog\//, '').split(/[^A-Za-z0-9\-\_]/)[0].strip
      return 1, "http://www.somewhereinblog.net/blog/#{blog_name}"
    when /^(http\:\/\/)?(www\.)?(sachalayatan|socholayoton)/
      blog_name = p_url.gsub(/http\:\/\/|www\.|sachalayatan\.com\/||socholayoton\.com\//, '').split(/[^A-Za-z0-9\-\_]/)[0].strip
      return 2, "http://www.sachalayatan.com/#{blog_name}"
    when /^(http\:\/\/)?(www\.)?([A-Za-z0-9\-\_])+\.blogspot\.com/
      blog_name = p_url.gsub(/http\:\/\/|www\.|blogspot\.com\/[\w\d\/\-\_]+/, '').split(/[^A-Za-z0-9\-\_]/)[0].strip
      return 3, "http://#{blog_name}.blogspot.com"
#    when /(http\:\/\/)?(www\.)?prothom-aloblog/
#      blog_name = p_url.gsub(/http\:\/\/|www\.|prothom-aloblog\.com\/|users\/|base\//, '').split(/[^A-Za-z0-9\-\_]/)[0].strip
#      return 3, "http://prothom-aloblog.com/users/base/#{blog_name}"
    end
    return nil, nil
  end
end
