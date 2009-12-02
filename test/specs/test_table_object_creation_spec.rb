require "spec"
require File.dirname(__FILE__) + "/../../lib/test_object"
describe "Create Test Table Object" do

  # Called before each example.
  before(:each) do
    # Do nothing
    @t_obj = TestObject.new("HomePage/HelloTest/table_1")

    @table = <<-TABLE
<a class="table-button"><img  src="/images/play_button_small.png" alt="run tests"/></a>
<a class="table-button"><img src="/images/edit_small.png" alt="edit table"/></a>
<p>Fixture Class: <strong>mock_fixture</strong></p>
<table cellpadding="0" cellspacing="0">
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
    TABLE

     @table.gsub!(/\s+/,"")
  end



  # Called after each example.
  after(:each) do
    # Do nothing
  end

  it "should create a test object from a file" do

    #To change this template use File | Settings | File Templates.

    @t_obj.should_not == nil
    @t_obj.component_type.should == "table"

  end

  it "should emit an HTML version of its content" do
    html = @t_obj.to_html
    html.gsub!(/\s+/,"")
    html.should == @table
  end

  it "should put the name of the element in the object hash" do
    name = @t_obj.get_name
    name.should == "table_1"
  end

  it "should delete a file upon request" do
    File.open("testfile.txt","w") do |f|
      1.upto(100) {|i| f.write(i.to_s + "\n")}
    end

    File.delete("testfile.txt")
    puts Dir.pwd
    File.delete(Dir.pwd + File::SEPARATOR + "specs" + File::SEPARATOR + "delete_file.yml") #if File.exists?("delete_file.yml")
  end

  
end