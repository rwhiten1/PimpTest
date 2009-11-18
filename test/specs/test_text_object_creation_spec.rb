require "spec"
require File.dirname(__FILE__) + "/../../lib/test_object"

describe "Create Text Object" do

  # Called before each example.
  before(:each) do
    @t_obj = TestObject.new("HomePage/HelloTest/text_1")
    @text = "<p>This is some text that will go on the page.  It will be<br/> stuck inside a paragraph tag.  All newlines will be replaced<br/> with &lt;br&gt; tags.<br/></p>"

  end

  # Called after each example.
  after(:each) do
    # Do nothing
  end

  it "should create a text object from a file" do

    @t_obj.should_not == nil
    @t_obj.component_type.should == "text"
  end

  it "should emit an HTML version of its content" do
    html = @t_obj.to_html
    html.should == @text
  end
end