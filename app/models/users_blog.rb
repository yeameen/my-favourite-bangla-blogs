class UsersBlog < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog

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
    if blog.nil?
      blog = Blog.create(:url => formatted_url, :site_id => site_id)
    end
    self.blog_id = blog.id
  end

  private
  def format_url(p_url)
    case p_url
    when /^(http\:\/\/)?(www\.)?somewhereinblog/
      blog_name = p_url.gsub(/http\:\/\/|www\.|somewhereinblog\.net\//, '').gsub(/^blog\//, '').split(/[^A-Za-z0-9\-\_]/)[0].strip
      return 1, "http://www.somewhereinblog.net/blog/#{blog_name}"
    when /^(http\:\/\/)?(www\.)?(sachalayatan|socholayoton)/
      blog_name = p_url.gsub(/http\:\/\/|www\.|sachalayatan\.com\//, '').split(/[^A-Za-z0-9\-\_]/)[0].strip
      return 2, "http://www.sachalayatan.com/#{blog_name}"
    end
    return nil, nil
  end
end
