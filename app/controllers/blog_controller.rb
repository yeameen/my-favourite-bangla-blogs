class BlogController < ApplicationController
  before_filter :authorize
  
  def index
    redirect_to :action => :list
  end
  
  def list
#    @blogs = Blog.paginate(:all, :page => params[:page])
    @blogs = Blog.paginate_by_sql(["SELECT blogs.id, blogs.url, users_blogs.created_at, users_blogs.comment, sites.address_format
                                    FROM blogs
                                    INNER JOIN users_blogs ON blogs.id = users_blogs.blog_id
                                    INNER JOIN users ON users_blogs.user_id = users.id
                                    INNER JOIN sites ON blogs.site_id = sites.id
                                    WHERE users.id = ?", active_user.user_id], :page => params[:page])
#    raise "user id - #{session[:user].user_id}"
#    @active_user = User.find(session[:user].user_id)
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
      end
      redirect_to :action => 'list'
    end
  end

  def delete
  end
end
