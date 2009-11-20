require 'rubygems'
require "spec"
require "yaml"
require File.dirname(__FILE__) + "/../lib/parse_fixture.rb"

describe "Parse a fixture" do

  before(:all) do
    #see what directory we are running from
    File.delete(Dir.pwd + "/fixtures/fake_fixture.yml") if File.exists?(Dir.pwd + "/fixtures/fake_fixture.yml")
    @curr_dir = Dir.pwd
    Dir.chdir("test") if Dir.pwd =~ /PimpTest$/
  end
  
  before(:each) do
    @meta = YAML::load(File.open(File.dirname(__FILE__)+ "/fixtures/fake_fixture_test.yml"))
    @parser = FixtureParser.new("fake_fixture.rb")
    @parser.parse_file
    comment = <<-COMMENT
Fake Fixture Method 1.
This basically just prints out some values.  If the method really
did something special it would be documented here
params:: @var1 @var4
type:: table
---
format:
 |var1|var4|fake_method_one|
 |data1|data4|expected result|
COMMENT
  @comment_lines = comment.split("\n")


    method = <<-METHOD
  def method_name(arg1,arg2)
     if some_cond then
      #this here is a comment
        var.each do |e|
           assign if condition
        end
     else
      #this is alsoa  comment
        var.each do |f|
           if cond then
            assign
           end
        end

     end
    some info
  end
#comment
#comment
    METHOD

    @method_lines = method.split("\n")
  end
  
  after(:all) do
    Dir.chdir(@curr_dir)
    puts "Reset dir to: #{Dir.pwd}"
  end

  it "should return the class name" do
    @parser.get_class.should == "FakeFixtureClass"
  end

  it "should parse out each fixture method into a hash" do
     methods = @parser.get_methods
     methods.size.should == 2
     methods.key?(:fake_method_one).should == true
     methods.key?(:fake_method_two).should == true
  end

  it "should enter each comment block into a hash" do
    @parser.comments.size.should == 3
    @parser.comments.key?(:FakeFixtureClass).should == true
    @parser.comments.key?(:fake_method_one).should == true
    @parser.comments.key?(:fake_method_two).should == true
    @comment_lines.should == @parser.comments[:fake_method_one]

  end

  it "should keep track of when parsing method contents" do
    count = 0
    in_a_method = false
    @method_lines.each do |line|
      in_a_method = @parser.in_method?(line)
      count += 1
      break if !in_a_method
    end
    in_a_method.should == false
    count.should == @method_lines.size - 2
  end

  it "should create meta information from a comment" do
    fix_one = @parser.parse_comment(@comment_lines)
    fix_one[:info].should == @meta[:fake_method_one][:info]
    fix_one[:params].should == @meta[:fake_method_one][:params]
    fix_one[:type].should == @meta[:fake_method_one][:type]
    fix_one[:format].should == @meta[:fake_method_one][:format]
  end

  it "should create fixture meta data from comments" do
     first = @meta[:fake_method_one]
     @parser.build_meta_information
    first[:format].should == @parser.get_meta_info(:fake_method_one)[:format]
    first[:params].should == @parser.get_meta_info(:fake_method_one)[:params]
    File.exists?(Dir.pwd + "/fixtures/fake_fixture.yml").should == true
  end
end