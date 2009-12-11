require "spec"
require "yaml"
require File.dirname(__FILE__) + "/../../lib/test_page"
require "fileutils"

describe "Create Test Page" do

  # Called before each example.
  before(:each) do

    if File.exists?(Dir.pwd + "/HomePage/HelloTest/NewChild")
    current = Dir.pwd
    Dir.chdir(Dir.pwd + "/HomePage/HelloTest")
    FileUtils.rm_rf("/")
    end

    # Do nothing
    @page_text = <<PAGE
<div class=\"text black-border\" id=\"text_1\">
<p>This is some text that will go on the page.  It will be<br/> stuck inside a paragraph tag.  All newlines will be replaced<br/> with &lt;br&gt; tags.<br/></p>
</div>
<br/>
<div class=\"table black-border\" id=\"table_1\">
<a class=\"table-button\"><img  src=\"/images/play_button_small.png\" alt=\"run tests\"/></a>
<a class=\"table-button\"><img src=\"/images/edit_small.png\" alt=\"edit table\"/></a>
<a class="table_button" onclick="javascript: deleteElement('table_1')">X</a>
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
<li><a href="HomePage/HelloTest/FirstChild">FirstChild</a></li>
<li><a href="HomePage/HelloTest/SecondChild">SecondChild</a></li>
<li><a href="HomePage/HelloTest/ThirdChild">ThirdChild</a></li>
</ul>
LIST



    @newfixture = <<FIX
<div class=\"table black-border\" id=\"table_2\">
<a class="table-button"><img  src="/images/play_button_small.png" alt="run tests"/></a>
<a class="table-button"><img src="/images/edit_small.png" alt="edit table"/></a>
<a class="table_button" onclick="javascript: deleteElement('table_2')">X</a>
<p>Fixture Class: <strong>mock_fixture</strong></p>
<table cellpadding="0" cellspacing="0">
    <thead>
        <tr>
                <td>var1</td>        
                <td>var4</td>
                <td>fake_method_one</td>
        </tr>
    </thead>
       <tr>
                <td>data1</td>
                <td>data4</td>
                <td>expected result</td>
        </tr>
 </table>
</div>
FIX

    @children.gsub!(/\s+/,"") #replace whitespace
    @page_text.gsub!(/\s+/,"")
    @newfixture.gsub!(/\s+/,"")
  end

  # Called after each example.
  after(:each) do
    
  end



  it "should create a page from the yaml file in a directory" do

    #To change this template use File | Settings | File Templates.
    page = TestPage.new("HomePage/HelloTest")
    html = page.generate
    html = html.gsub(/\s+/,"")
    html.should == @page_text
  end

  it "should return a list of child pages" do
    page = TestPage.new("HomePage/HelloTest")
    html_list = page.get_child_list
    html_list.gsub!(/\s+/,"") #replace whitespace
    html_list.should == @children
  end

  it "should be able to add new fixture tables to a page" do
    puts "Current Dir: #{Dir.pwd}"
    page = TestPage.new("HomePage/HelloTest")
    fixture = {:name => "fake_fixture",
               :method => "fake_method_one",
               :position => :last,
               :path => "/HomePage/HelloTest"}

    #Verify the HTML output is valid
    html = page.add_fixture(fixture)
    html.gsub!(/\s+/,"")
    html.should == @newfixture

    #now, verify the yamls have been updated
    page = YAML::load(File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml"))
    order = page[:order]
    order.size.should == 3
    order[order.size - 1].should == "table_2"
    table_2 = page[:table_2]
    table_2.size.should == 4
    table_2[:content].should == [["var1","var4","fake_method_one"],["data1","data4","expected result"]]

    #clean up the page hash, then save it back to the file
    order.delete("table_2")
    page.delete(:table_2)
    File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml","w") do |io|
      YAML::dump(page,io)
    end
  end

  it "should be able to delete an element from a page" do
    puts "Current Dir: #{Dir.pwd}"
    #First, add a fixture to the page:
    page = TestPage.new("HomePage/HelloTest")
    fixture = {:name => "fake_fixture",
               :method => "fake_method_one",
               :position => :last,
               :path => "/HomePage/HelloTest"}

    #Verify the HTML output is valid
    page.add_fixture(fixture)
    page = nil
    
    #now, delete the fixture
    page = TestPage.new("HomePage/HelloTest")
    html = page.delete_element({:element => "table_2", :path => "HomePage/HelloTest"})

    page = YAML::load(File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml"))
    order = page[:order]
    order.size.should == 2
    page[:table_2].should == nil
  end

  it "should be able to add a new child page page" do
    page = TestPage.new("HomePage/HelloTest")
    page.add_child({:name => "NewChild"})

    #look to see if there is a new directory under the current page
    File.exists?(File.dirname(__FILE__) + "/../HomePage/HelloTest/NewChild").should == true
    File.exists?(File.dirname(__FILE__) + "/../HomePage/HelloTest/NewChild/page.yml").should == true

  end

  it "should be able to add a new text block to a page" do
      page = TestPage.new("HomePage/HelloTest")
      page.add_text_element({:text => "This here is some brand new text for your page!", :after=>"text_1"})

      page_config = YAML::load(File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml"))

      #is the new text element in the page config, and is the correct text there?
      page_config.key?(:text_2).should == true
      page_config[:text_2][:content].should == "This here is some brand new text for your page!"
      page_config[:text_2][:name].should == "text_2"

      #is the new text element in the right position?  (second in the order array)
      page_config[:order].size.should == 3
      page_config[:order][1].should == "text_2"
      #remove the new text element here.

      page_config[:order].delete("text_2")
      page_config.delete(:text_2)
      File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml","w") do |io|
        YAML.dump(page_config,io)
      end
  end

  it "should be able to add a new header to a page" do
    page = TestPage.new("HomePage/HelloTest")
    page.add_header_element({:header => "A New Heading!", :size => "4", :after=>"text_1"})
    page_config = YAML::load(File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml"))

    page_config.key?(:head_1).should == true
    page_config[:head_1][:content].should == "A New Heading!"
    page_config[:head_1][:name].should == "head_1"
    page_config[:head_1][:size].should == "4"
    page_config[:head_1][:type].should == "heading"

    #is the new text element in the right position?  (second in the order array)
    page_config[:order].size.should == 3
    page_config[:order][1].should == "head_1"

    page_config[:order].delete("head_1")
    page_config.delete(:head_1)
    File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml","w") do |io|
        YAML.dump(page_config,io)
    end
  end

  it "should be able to edit a header on a page" do
    page = TestPage.new("HomePage/HelloTest")
    #add a new header
    page.add_header_element({:header => "A New Heading!", :size => "4", :after=>"text_1"})

    #now, edit the header
    html = page.edit_header(:name=>"head_1",:header=>"This has been edited")
    #now, get the config file and verify the edit
    page_config = YAML::load(File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml"))
    page_config[:head_1][:content].should == "This has been edited"
    page_config[:head_1][:size].should == "4"
    page_config[:order].size.should == 3
    page_config[:order][1].should == "head_1"
    #now, delete the header to clean up.
    page_config[:order].delete("head_1")
    page_config.delete(:head_1)
    File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml","w") do |io|
        YAML.dump(page_config,io)
    end
  end

  it "should be able to edit a text element on the page" do
    page = TestPage.new("HomePage/HelloTest")
    #add a text element to the page
    page.add_text_element({:text => "This here is some brand new text for your page!", :after=>"text_1"})

    page.edit_text({:text=>"The text has been edited.", :name=>"text_2"})
    page_config = YAML::load(File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml"))
    page_config[:text_2][:content].should == "The text has been edited."

    #now delete the element
    page_config[:order].delete("text_2")
    page_config.delete(:text_2)
    File.open(File.dirname(__FILE__)+ "/../HomePage/HelloTest/page.yml","w") do |io|
        YAML.dump(page_config,io)
    end
  end

  it "should be able to determine the next available name and position for an element" do
    #this represents the position array.
    arr = ["text_3", "table_1", "header_2", "text_1", "table_3","text_4"]
    page = TestPage.new("HomePage/HelloTest")

    #this should return what the name for the new element will be, it should be text_2
    name = page.make_new_name("text",arr)
    name.should == "text_2"

    #now, try it out but force the new name loop to count towards the bottom of the array
    arr = ["text_3","table_1","text_1","table_3","text_2","text_5"]
    name = page.make_new_name("text",arr)
    name.should == "text_4"

    #finally, make it count off the end of the list, this is in effect adding an
    #element name that has not been used before
    arr = ["text_3", "table_1","text_1","table_3","text_2","text_4"]
    name = page.make_new_name("text",arr)
    name.should == "text_5"
    
  end

end