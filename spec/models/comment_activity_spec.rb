require File.dirname(__FILE__) + '/../spec_helper'

describe CommentActivity, '#comments' do
  before(:each) do
    @comment = Factory.create(:comment)
  end
  
  it 'finds the 5 most recent approved comments for the post' do
    CommentActivity.new(@comment.post).comments.should == [@comment]
  end

  it 'is memoized to avoid excess hits to the DB' do
    activity = CommentActivity.new(@comment.post)
    @comment.post.should_receive(:approved_comments).once.and_return(mock('stub', :null_object => true))
    2.times { activity.comments }
  end
  
  it "should return the first comment of a post" do
    2.times { @comment.post.comments.create(Factory.attributes_for(:comment)) }
    first_id = @comment.post.comments.sort_by { |c| c.id }.first.id
    @comment.post.comments.size == 3 # 1 in the 'before's, 2 now
    CommentActivity.new(@comment.post).most_recent_comment.id.should == first_id
  end
  
  it "should return the most recent comments" do
    5.times { Factory.create(:comment) }
    CommentActivity.find_recent.should have(5).things
  end
end
