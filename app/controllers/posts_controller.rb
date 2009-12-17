class PostsController < ApplicationController
  def index
    @tag = params[:tag]
    @posts = Post.find_recent(:tag => @tag, :include => :tags)
    raise(ActiveRecord::RecordNotFound) if @tag && @posts.empty?
    fresh_when :etag => index_etag(@posts), :public => true

    respond_to do |format|
      format.html
      format.atom { render :layout => false }
    end if response.status == 200
  end

  def show
    @post = Post.find_by_permalink(*([:year, :month, :day, :slug].collect {|x| params[x] } << {:include => [:approved_comments, :tags]}))
    fresh_when :etag => @post.updated_at.to_i, :public => true
    @comment = Comment.new
  end
  
  private
  
    def index_etag(posts)
      posts.inject(0) do |etag, post|
        etag += post.updated_at.to_i + post.approved_comments_count.to_i
      end
    end
    
end
