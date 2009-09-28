# Enables Page Caching support for major controllers
if Enki::Config.default[:enable_sweepers]

  ::Admin::CommentsController.class_eval do
    cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy, :mark_as_ham, :mark_as_spam]
  end
  ::Admin::PagesController.class_eval do
    cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  end
  ::Admin::PostsController.class_eval do
    cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]
  end

  ::ArchivesController.class_eval do
    caches_page :index
  end
  ::CommentsController.class_eval do
    caches_page :index
    cache_sweeper :comment_sweeper, :only => [:create]
  end
  ::PagesController.class_eval do
    caches_page :show
  end
  ::PostsController.class_eval do
    caches_page :index
    caches_page :show
  end
end