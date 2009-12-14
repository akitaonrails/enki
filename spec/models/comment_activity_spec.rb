require File.dirname(__FILE__) + '/../spec_helper'

describe CommentActivity, '#comments' do
  
  def valid_comment_attributes(extra = {})
    {
      :author       => 'Don Alias',
      :author_url   => "me",
      :author_email => "me@fake.com",
      :body         => 'This is a comment',
      :post         => Post.create!(:title => 'My Post', :excerpt => "", :body => "body", :tag_list => "ruby")
    }.merge(extra)
  end

  context "find recent comments" do
    before :each do
      @comments = []
      (1..10).each do |n|
        @comments << Comment.create!(valid_comment_attributes(:created_at => Time.now - n * (60 * 60 * 24)))
      end
    end

    it "should have the comment activity sorted by when they were created" do
      comment_activity = CommentActivity.find_recent
      comment_activity.first.post.should == @comments.first.post
    end

    it do
      comment_activity = CommentActivity.find_recent
      comment_activity.should have_exactly(5).posts
    end

    it "should not return repeated posts" do
      comment = Comment.create! valid_comment_attributes(:post => Post.first, :created_at => Time.now)
      comment_activity = CommentActivity.find_recent
      comment_activity.select{|a| a.post == comment.post}.size.should == 1
    end

  end

  context "simple model operations" do
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
end
