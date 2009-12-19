class PagesController < ApplicationController
  def show
    @page = Page.find_by_slug(params[:id]) || raise(ActiveRecord::RecordNotFound)
    fresh_when :etag => @page.updated_at.to_i, :public => true
  end
end
