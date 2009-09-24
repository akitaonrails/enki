# Enables Page Caching support for major controllers
if Enki::Config.default[:enable_sweepers]
  class Admin::CommentsController < Admin::BaseController
    cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]
  end
  class Admin::PagesController < Admin::BaseController
    cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  end
  class Admin::PostsController < Admin::BaseController
    cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]
  end

  class ArchivesController < ApplicationController
    caches_page :index
  end
  class CommentsController < ApplicationController
    caches_page :index
    cache_sweeper :comment_sweeper, :only => [:create]
  end
  class PagesController < ApplicationController
    caches_page :show
  end
  class PostsController < ApplicationController
    caches_page :index
    caches_page :show
  end
end