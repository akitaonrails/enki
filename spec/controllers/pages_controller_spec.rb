require File.dirname(__FILE__) + '/../spec_helper'

describe PagesController do
  
  describe 'cacheable posts list', :shared => true do
    it "should setup cache control to public" do
      do_get
      response.headers["Cache-Control"].should == "public"
    end

    it "should setup ETag" do
      do_get
      response.headers["ETag"].should == '"4b87bd706071fca61acdff007a79742e"'
    end
  end
  
  describe 'handling GET for a single post' do
    before(:each) do
      @page = mock_model(Page, :updated_at => Time.utc(2009,1,1))
      Page.stub!(:find_by_slug).and_return(@page)
    end

    def do_get
      get :show, :id => 'a-page'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render show template" do
      do_get
      response.should render_template('show')
    end

    it 'should find the page requested' do
      Page.should_receive(:find_by_slug).with('a-page').and_return(@page)
      do_get
    end

    it 'should assign the page found for the view' do
      do_get
      assigns[:page].should equal(@page)
    end
    
    it_should_behave_like('cacheable posts list')
    
  end

  describe 'handling GET with invalid page' do
    it 'raises a RecordNotFound error' do
      Page.stub!(:find_by_slug).and_return(nil)
      lambda {
        get :show, :id => 'a-page'
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
