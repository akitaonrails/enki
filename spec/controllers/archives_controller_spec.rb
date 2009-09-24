require File.dirname(__FILE__) + '/../spec_helper'

describe ArchivesController do
  describe 'handling GET to index' do
    before(:each) do
      @posts = [mock_model(Post), mock_model(Post)]
      Post.stub!(:archives).and_return(mock(Object))
      Post.archives.stub!(:all).and_return(@posts)
    end

    def do_get
      get :index
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end

    it "should assign the found months for the view" do
      do_get
      assigns[:posts].should == @posts
    end

    it 'should find posts grouped by month' do
      mock_obj = mock(Object)
      mock_obj.should_receive(:all).and_return(@posts)
      Post.stub!(:archives).and_return(mock_obj)
      do_get
    end
  end
end
