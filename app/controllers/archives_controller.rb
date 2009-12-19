class ArchivesController < ApplicationController
  def index
    expires_in 12.hours, :public => true
    @months = Post.find_all_grouped_by_month
  end
end
