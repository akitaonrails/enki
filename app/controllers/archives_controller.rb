class ArchivesController < ApplicationController
  def index
    expires_in 12.hours, :public => true
    @posts = Post.archives(params).all
  end
end
