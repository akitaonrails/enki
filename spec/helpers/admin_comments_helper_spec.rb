require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::CommentsHelper do
  include Admin::CommentsHelper
  
  it "should render the mark as ham route" do
    @comment = Factory.create(:comment, :akismet => 'spam')
    akismet_url(@comment) == "/admin/comments/#{@comment.to_param}/mark_as_ham"
  end

  it "should render the mark as spam route" do
    @comment = Factory.create(:comment, :akismet => 'ham')
    akismet_url(@comment) == "/admin/comments/#{@comment.to_param}/mark_as_spam"
  end

end