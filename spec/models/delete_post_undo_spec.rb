require File.dirname(__FILE__) + '/../spec_helper'

describe DeletePostUndo do
  describe '#process!' do
    it 'creates a new post based on the attributes stored in #data' do
      Post.stub!(:find_by_id).and_return(nil)
      
      item = DeletePostUndo.new(:data => "--- \n:post: \n  id: 1\n  slug: foo\n  title: Foo\n:comments: \n- author: AkitaOnRails\n")
      item.stub!(:transaction).and_yield
      item.stub!(:destroy)

      mock_comments = mock()
      mock_comments.stub!(:create!)
      mock_post = mock("post", :new_record? => false)
      mock_post.stub!(:comments).and_return(mock_comments)
      Post.should_receive(:create!).with('slug' => 'foo', 'title' => 'Foo').and_return(mock_post)
      item.process!
    end
  end

  describe '#process! with existing post' do
    it 'raises' do
      Post.stub!(:find_by_id).and_return(Object.new)
      lambda { DeletePostUndo.new(:data => "--- \n:post: \n  id: 1\n").process! }.should raise_error(UndoFailed)
    end
  end

  describe '#process! with invalid post' do
    it 'raises' do
      Post.stub!(:find_by_id).and_return(nil)

      Post.stub!(:create!).and_return(mock("post", :new_record? => true))
      lambda { DeletePostUndo.new(:data => "--- \n:post: \n  id: 1\n  slug: foo\n  title: Foo\n:comments: \n- author: AkitaOnRails\n").process! }.should raise_error(UndoFailed)
    end
  end

  describe '#description' do
    it("should not be nil") { DeletePostUndo.new(:data => "--- \n:post: \n").description.should_not be_nil }
  end

  describe '#complete_description' do
    it("should not be nil") { DeletePostUndo.new(:data => "--- \n:post: \n").complete_description.should_not be_nil }
  end

  describe '.create_undo' do
    it "creates a new undo item based on the attributes of the given post" do
      post = Post.new(:title => 'Don Alias')
      DeletePostUndo.should_receive(:create!).with(:data => {:post => post.attributes, :comments => post.comments.collect(&:attributes)}.to_yaml).and_return(obj = Object.new)
      DeletePostUndo.create_undo(post).should == obj
    end
  end
end
