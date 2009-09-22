require File.dirname(__FILE__) + '/../spec_helper'

describe UndoItem do
  it "should raise error" do
    lambda { 
      UndoItem.new.process! 
    }.should raise_error("#process must be implemented by subclasses")    
  end
end