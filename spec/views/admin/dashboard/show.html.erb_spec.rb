require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/dashboard/show.html.erb" do
  after(:each) do
    response.should be_valid_xhtml_fragment
  end

  it 'should render' do
    assigns[:posts] = [Factory.create(:post,
      :title             => 'A Post',
      :published_at      => Time.now
      )]
    assigns[:comment_activity] = [mock("comment-activity-1",
      :post                => Factory.create(:post, 
        :published_at      => Time.now,
        :title             => "A Post"
      ),
      :comments            => [Factory.create(:comment, :author => 'Don', :body => 'Hello')],
      :most_recent_comment => Factory.create(:comment, :created_at => Time.now, :author => 'Don')
    )]
    assigns[:stats] = Struct.new(:post_count, :comment_count, :tag_count).new(3,2,1)
    render '/admin/dashboard/show.html.erb'
  end
end
