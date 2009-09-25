class CommentsController < ApplicationController
  include UrlHelper
  has_rakismet
  
  OPEN_ID_ERRORS = { 
    :missing  => "Sorry, the OpenID server couldn't be found", 
    :canceled => "OpenID verification was canceled",
    :failed   => "Sorry, the OpenID verification failed" }

  before_filter :find_post, :except => [:new]

  def index
    if request.post? || using_open_id?
      create
    else
      respond_to do |format|
        format.html do
          @post ? redirect_to(post_path(@post)) : redirect_to(root_path)
        end
        format.atom do
          @comments =  @post ? @post.approved_comments.all : Comment.latests(:joins => :post).all
        end
      end
    end
  end

  def new
    @comment = Comment.build_for_preview(params[:comment])

    respond_to do |format|
      format.js do
        render :partial => 'comment.html.erb'
      end
    end
  end

  def create    
    @comment = Comment.new((session[:pending_comment] || params[:comment] || {}).reject {|key, value| !Comment.protected_attribute?(key) })
    @comment.post = @post
    # spam protection - if someone fill in the hidden 'email' field, it's a bot
    if !params[:email].blank? || @comment.body.size < 10
      redirect_to post_path(@post)
      return
    end

    session[:pending_comment] = nil

    unless @comment.requires_openid_authentication?
      @comment.blank_openid_fields
    else
      session[:pending_comment] = params[:comment]
      return if authenticate_with_open_id(@comment.author, :optional => [:nickname, :fullname, :email]) do |result, identity_url, registration|
        if result.status == :successful
          @comment.post = @post

          @comment.author_url   = @comment.author
          @comment.author       = (registration["fullname"] || registration["nickname"] || @comment.author_url).to_s
          @comment.author_email = (registration["email"] || @comment.author_url).to_s

          @comment.openid_error = ""
          session[:pending_comment] = nil
        else
          @comment.openid_error = OPEN_ID_ERRORS[ result.status ]
        end
      end
    end
    # record client's ip
    @comment.user_ip = request.remote_ip
    @comment.referrer = request.referrer
    
    if session[:pending_comment].nil? && @comment.save
      if Enki::Config.default[:comment_start_as] == 'spam'
        flash[:notice] = 'Your comment is awaiting for approval.'
      end
      redirect_to post_path(@post)
    else
      render :template => 'posts/show'
    end
  end

  protected

  def find_post
    if params.keys.include?(:year) or params.keys.include?("year")
      @post = Post.find_by_permalink(*[:year, :month, :day, :slug].collect {|x| params[x] })
    end
  end
end
