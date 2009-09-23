require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/comments/index.html.erb" do
  after(:each) do
    response.should be_valid_xhtml_fragment
  end

  it 'should render' do
    comments = [Factory.create(:comment)]
    comments.stub!(:total_pages).and_return(1)
    assigns[:comments] = comments
    render '/admin/comments/index.html.erb'
  end
end
