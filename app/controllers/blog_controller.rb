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
                                                :conditions => {:user_id => active_user.user_id, :is_new => true},
                                                :order => "weight ASC",
                                                :limit => BlogRecommendation::SIZE_RECOMMENDATIONS)

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
    raise "error"
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
        blog_recommendation = BlogRecommendation.find(:first,
                                                      :conditions => {:blog_id => @user_blog.blog.id,
                                                                      :user_id => active_user().user_id})
        unless blog_recommendation.nil?
          blog_recommendation.is_new = false
          blog_recommendation.reject = false
          blog_recommendation.save
        end
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


#  public
#  def reject_recommendation
#    user_id = active_user().user_id
#    blog_recommendation = BlogRecommendation.find(:first,
#                                                  :conditions => {:user_id => user_id, :id => params[:id]})
#    if blog_recommendation.nil?
#      render :text => "illegal access" and return
#    else
#      logger.debug("\nRejecting recommendation")
#      log_recommendation.rejecct()
#    end
#  end

  public
  def update_recommendation
    user_id = active_user().user_id
    blog_recommendation = BlogRecommendation.find(:first,
                                                  :conditions => {:user_id => user_id, :id => params[:id]})
    if blog_recommendation.nil?
      render :text => "illegal access" and return
    else
      logger.debug("\n\nParameter - #{params[:rec]}\n\n")
      if params[:rec] == "Accept"
        logger.debug("\n\nAccepting...")
        blog_recommendation.accept(params[:user_blog][:comment])
      else
        logger.debug("\n\nRejecting...")
#        blog_recommendation.is_new = false
#        blog_recommendation.is_rejected = true
        blog_recommendation.reject()
      end
      blog_recommendation.save
    end
    @blog_recommendation = blog_recommendation
  end
end
