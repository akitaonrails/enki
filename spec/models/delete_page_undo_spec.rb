require File.dirname(__FILE__) + '/../spec_helper'

describe DeletePageUndo do
  describe '#process!' do
    it 'creates a new page based on the attributes stored in #data' do
      Page.stub!(:find_by_id).and_return(nil)
      
      item = DeletePageUndo.new(:data => "---\nid: 1\na: b")
      item.stub!(:transaction).and_yield
      item.stub!(:destroy)

      Page.should_receive(:create!).with('a' => 'b').and_return(mock("page", :new_record? => false))
      item.process!
    end
  end

  describe '#process! with existing page' do
    it 'raises' do
      Page.stub!(:find_by_id).and_return(Object.new)
      lambda { DeletePageUndo.new(:data => "---\nid: 1").process! }.should raise_error(UndoFailed)
    end
  end

  describe '#process! with invalid page' do
    it 'raises' do
      Page.stub!(:find_by_id).and_return(nil)

      Page.stub!(:create!).and_return(mock("page", :new_record? => true))
      lambda { DeletePageUndo.new(:data => "---\nid: 1").process! }.should raise_error(UndoFailed)
    end
  end

  describe '#description' do
    it("should not be nil") { DeletePageUndo.new(:data => '---').description.should_not be_nil }
  end

  describe '#complete_description' do
    it("should not be nil") { DeletePageUndo.new(:data => '---').complete_description.should_not be_nil }
  end

  describe '.create_undo' do
    it "creates a new undo item based on the attributes of the given page" do
      page = Page.new(:title => 'Don Alias')
      DeletePageUndo.should_receive(:create!).with(:data => page.attributes.to_yaml).and_return(obj = Object.new)
      DeletePageUndo.create_undo(page).should == obj
    end
  end
end
