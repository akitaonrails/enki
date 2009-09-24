class ArchivesController < ApplicationController
  def index
    @posts = Post.archives(params).all
  end
end
