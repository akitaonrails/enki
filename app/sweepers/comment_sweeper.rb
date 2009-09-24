class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment
  include ActionController::UrlWriter
  include UrlHelper
  
  def after_create(comment)
    expire_cache_for(comment)
  end
  
  def after_update(comment)
    expire_cache_for(comment)
  end
  
  def after_destroy(comment)
    expire_cache_for(comment)
  end
  
  private
  
  def expire_cache_for(comment)
    FileUtils.rm_rf("#{ActionController::Base.page_cache_directory}/index.html")
    Dir.glob("#{RAILS_ROOT}/tmp/cache/views/*").each do |dir|
      FileUtils.rm_rf("#{dir}#{post_path(comment.post)}.cache")
    end
  end
end