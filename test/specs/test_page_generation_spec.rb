require "spec"
require File.dirname(__FILE__) + "/../../lib/test_page"

describe "Create Test Page" do

  # Called before each example.
  before(:each) do
    # Do nothing
    @page_text = <<PAGE
<div class=\"text\" id=\"text_1\">
<p>This is some text that will go on the page.  It will be<br/> stuck inside a paragraph tag.  All newlines will be replaced<br/> with &lt;br&gt; tags.<br/></p>
</div>
<br/>
<div class=\"table\" id=\"table_1\">
<a class=\"table-button\"><img  src=\"/images/play_button_small.png\" alt=\"run tests\"/></a>
<a class=\"table-button\"><img src=\"/images/edit_small.png\" alt=\"edit table\"/></a>
<p>Fixture Class: <strong>mock_fixture</strong></p>
<table cellpadding=\"0\" cellspacing=\"0\">
<thead>
<tr>
<td>var1</td>
<td>var2</td>
<td>var3</td>
<td>var4</td>
<td>run_this_method</td>
</tr>
</thead>
<tr>
<td>data</td>
<td>to</td>
<td>put</td>
<td>in test</td>
<td>expected result</td>
</tr>
</table>

</div>
PAGE


    @children = <<LIST
<h4>Pages</h4>
<ul class="child_pages">
<li><a href="/HomePage/HelloTest/FirstChild">FirstChild</a></li>
<li><a href="/HomePage/HelloTest/SecondChild">SecondChild</a></li>
<li><a href="/HomePage/HelloTest/ThirdChild">ThirdChild</a></li>
</ul>
LIST
    @children.gsub!(/\s+/,"") #replace whitespace
    @page_text.gsub!("\n","")
  end

  # Called after each example.
  after(:each) do
    # Do nothing
  end

  it "should create a page from yaml files in a directory" do

    #To change this template use File | Settings | File Templates.
    page = TestPage.new("HomePage/HelloTest")
    html = page.generate
    html = html.gsub("\n","")
    html.should == @page_text
  end

  it "should return a list of child pages" do
    page = TestPage.new("HomePage/HelloTest")
    html_list = page.get_child_list
    html_list.gsub!(/\s+/,"") #replace whitespace
    html_list.should == @children
  end
end