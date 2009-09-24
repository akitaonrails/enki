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
      FileUtils.rm_rf(file) unless file =~ /[404|422|500]\.html$/
    end
    Dir.glob("#{ActionController::Base.page_cache_directory}/*.atom") do |file|
      FileUtils.rm_rf(file) unless file =~ /[404|422|500]\.html$/
    end
    Dir.glob("#{RAILS_ROOT}/tmp/cache/views/*").each do |dir|
      FileUtils.rm_rf("#{dir}#{post_path(post)}.cache")
      FileUtils.rm_rf("#{dir}/posts/#{post.id}/print.cache")
    end
    expire_page(archives_path(:month => post.published_at.month, :year => post.published_at.year))
  end
end