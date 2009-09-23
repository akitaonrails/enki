require File.dirname(__FILE__) + '/../spec_helper'

describe Upload do
  before do
    @upload = Upload.new(:avatar => fixture_file_upload('rails.png'))
  end
  
  it "should receive a file upload, convert it and save its metadata" do
    @upload.save.should be_true
  end
  
  it "should return the most recent uploads" do
    @upload.save
    Upload.recents.should == [@upload]
  end
end
