class BlogController < ApplicationController
  layout "template"
  
  before_filter :authorize, :except => [:view_post]
  
  def index
    redirect_to :action => :list
  end
  
  def list
    user = active_user()
    @blogs = user.blogs.paginate(:all, :page => params[:page])

    @recommended_blogs = BlogRecommendation.find(:all,
                                                :conditions => {:user_id => active_user.id, :is_new => true},
                                                :order => "weight ASC",
                                                :limit => BlogRecommendation::SIZE_RECOMMENDATIONS)
  end

  def posts
    user = active_user()
    @user_posts = UsersPost.paginate( :all,
                                      :include => [:post],
                                      :order => "posts.posted_at DESC",
                                      :conditions => {:user_id => user.id}, :page => params[:page], :per_page => 20)
  end

  def view_post
    return unless params[:id].to_i > 0
    user = active_user()
    post = Post.find(params[:id])

    unless user.nil?
      user_post = UsersPost.find(:first, :conditions => {:post_id => params[:id], :user_id => user.id})
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
      @user_blog = UsersBlog.find(:first, :conditions => {:user_id => active_user().id, :blog_id => params[:id]})
      raise "User Blog not found" if @user_blog.nil?
    rescue
      logger.debug("Exception occured - #{$!}")
      @user_blog = UsersBlog.new(:user_id => active_user().id)
    end

    if request.post?
      @user_blog.attributes = params[:user_blog]

      unless @user_blog.save
        flash[:notice] = "Couldn't save blog"

      else # update recommendation
        blog_recommendation = BlogRecommendation.find(:first,
                                                      :conditions => {:blog_id => @user_blog.blog.id,
                                                                      :user_id => active_user().id})
        unless blog_recommendation.nil?
          blog_recommendation.accept()
          blog_recommendation.save
        end
        puts "updating blog recommendations\n\n\n"
        BlogRecommendation.update_recommendations()
      end

      redirect_to :action => 'list'
    end
  end

  public
  def delete_blog
    @user_blog = UsersBlog.find(:first, :conditions => {:user_id => active_user().id, :blog_id => params[:id]})
    unless @user_blog.nil?
      @user_blog.destroy
    end
  end

  public
  def delete_post
    @user_post = UsersPost.find(:first, :conditions => {:user_id => active_user().id, :post_id => params[:id]})
    unless @user_post.nil?
      @user_post.destroy
    end
  end


#  public
#  def reject_recommendation
#    user_id = active_user().id
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
                                                  :conditions => {:user_id => user_id, :blog_id => params[:id]})
    if blog_recommendation.nil?
      render :text => "illegal access" and return
    else
      logger.debug("\n\nParameter - #{params[:rec]}\n\n")
      if params[:rec] == "Accept"
        @recommendation_action = "accept"
        logger.debug("\n\nAccepting...")
        blog_recommendation.accept(params[:user_blog][:comment])
      else
        logger.debug("\n\nRejecting...")
        @recommendation_action = "reject"
#        blog_recommendation.is_new = false
#        blog_recommendation.is_rejected = true
        blog_recommendation.reject()
      end
      blog_recommendation.save
    end
    @blog_id = blog_recommendation.blog_id
    BlogRecommendation.update_recommendations()
  end
end
