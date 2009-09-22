require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  include ApplicationHelper
  
  it "should format comment errors" do
    comment = Comment.new
    comment.stub!(:post).and_return(mock_model(Post, :id => 1))
    comment.valid?
    comment.errors.sort_by(&:first).each do |error|
      format_comment_error(error).should =~ /Please/
    end
  end
end
