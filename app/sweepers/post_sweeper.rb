class PostSweeper < ActionController::Caching::Sweeper
  observe Post
  include ActionController::UrlWriter
  include UrlHelper
  
  def after_create(post)
    expire_cache_for(post)
  end
  
  def after_update(post)
    expire_cache_for(post)
  end
  
  def after_destroy(post)
    expire_cache_for(post)
  end
  
  private
  
  def expire_cache_for(post)
    Dir.glob("#{ActionController::Base.page_cache_directory}/*.html") do |file|
      erase(file) unless file =~ /[404|422|500]\.html$/
    end
    Dir.glob("#{ActionController::Base.page_cache_directory}/*.atom") do |file|
      erase(file) unless file =~ /[404|422|500]\.html$/
    end
    Dir.glob("#{RAILS_ROOT}/tmp/cache/views/*").each do |dir|
      erase("#{dir}#{post_path(post)}.cache")
      erase("#{dir}/posts/#{post.id}/print.cache")
    end
    expire_page(post_path(post))
    expire_page(archives_path(:month => post.published_at.month, :year => post.published_at.year))
  end
  
  def erase(path)
    FileUtils.rm_rf(path)
    logger.info("  Expiring: #{path}")
  end
end