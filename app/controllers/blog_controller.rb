class BlogController < ApplicationController
  layout "template"
  
  before_filter :authorize, :except => [:view_post]
  
  def index
    redirect_to :action => :list
  end
  
  def list
    @blogs = Blog.paginate_by_sql(["SELECT
                                       blogs.id, blogs.url, users_blogs.created_at, users_blogs.comment,
                                       sites.address_format, sites.name as site_name
                                    FROM blogs
                                      INNER JOIN users_blogs ON blogs.id = users_blogs.blog_id
                                      INNER JOIN users ON users_blogs.user_id = users.id
                                      INNER JOIN sites ON blogs.site_id = sites.id
                                    WHERE users.id = ?
                                    ORDER BY users_blogs.created_at DESC",
                                    active_user.user_id], :page => params[:page])
     @recommended_blogs = BlogRecommendation.find(:all,
                                                :conditions => {:user_id => active_user.user_id},
                                                :order => "created_at ASC",
                                                :limit => 3)

#    @blogs = Blog.paginate(:all,
#      :select => "blogs.id, blogs.url, users_blogs.created_at, users_blogs.comment, sites.address_format, sites.name AS site_name",
#      :joins => "INNER JOIN users_blogs ON blogs.id = users_blogs.blog_id
#                 INNER JOIN users ON users_blogs.user_id = users.id
#                 INNER JOIN sites ON blogs.site_id = sites.id",
#      :conditions => ["users.id = ?", active_user.user_id],
##      :orderby => "users_blogs.created by DES",
#      :page => params[:page]
#    )
  end

  def posts
    user = active_user()
    @user_posts = UsersPost.paginate( :all,
                                      :include => [:post],
                                      :order => "posts.posted_at DESC",
                                      :conditions => {:user_id => user.user_id}, :page => params[:page], :per_page => 20)
  end

  def view_post
    return unless params[:id].to_i > 0
    user = active_user()
    post = Post.find(params[:id])

    unless user.nil?
      user_post = UsersPost.find(:first, :conditions => {:post_id => params[:id], :user_id => user.user_id})
      unless user_post.nil?
        user_post.is_read = 1
        user_post.num_old_comments = post.num_comments
        user_post.save
      end
    end
    redirect_to post.url
  end

  def edit
    begin
      @user_blog = UsersBlog.find(:first, :conditions => {:user_id => active_user().user_id, :blog_id => params[:id]})
      raise "User Blog not found" if @user_blog.nil?
    rescue
      logger.debug("Exception occured - #{$!}")
      @user_blog = UsersBlog.new(:user_id => active_user().user_id)
    end

    if request.post?
      @user_blog.attributes = params[:user_blog]

      unless @user_blog.save
        flash[:notice] = "Couldn't save blog"

      else # update recommendation
        BlogRecommendation.update_recommendations()
      end

      redirect_to :action => 'list'
    end
  end

  public
  def delete_blog
    @user_blog = UsersBlog.find(:first, :conditions => {:user_id => active_user().user_id, :blog_id => params[:id]})
    unless @user_blog.nil?
      @user_blog.destroy
    end
  end

  public
  def delete_post
    @user_post = UsersPost.find(:first, :conditions => {:user_id => active_user().user_id, :post_id => params[:id]})
    unless @user_post.nil?
      @user_post.destroy
    end
  end
end
