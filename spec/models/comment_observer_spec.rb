require File.dirname(__FILE__) + '/../spec_helper'

CommentObserver.class_eval do
  private_methods.each { |method| public_class_method method } 
end  

describe CommentObserver do
  
  before(:each) do
    @now = Time.now
    Time.stub!(:now).and_return(@now)
    @post = Post.new
    @comment = Comment.new(:post => @post)
    @observer = CommentObserver.new
  end
  
  it "should change post.update_at after save" do
    @post.should_receive(:update_attribute).with(:updated_at, @now)
    @observer.after_save(@comment)
  end
  
  it "should change post.update_at after destroy" do
    @post.should_receive(:update_attribute).with(:updated_at, @now)
    @observer.after_destroy(@comment)
  end
  
  it "should register comment observer" do
    ActiveRecord::Base.observers.include?(:comment_observer).should be_true
  end
  
end
