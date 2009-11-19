require "spec"
require "yaml"
require File.dirname(__FILE__) + "/../lib/parse_fixture.rb"

describe "Parse a fixture" do

  before(:each) do
     @meta = YAML::load(File.open(File.dirname(__FILE__)+ "/fixtures/fake_fixture.yml"))
    @parser = FixtureParser.new("fake_fixture.rb")
    @parser.parse_file
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

  end

  it "should create fixture meta data from comments" do
     first = @meta[:fake_method_one]
    first[:format].should == @parser.get_meta_info(:fake_method_one)[:format]
    first[:params].should <=> @parser.get_meta_info(:fake_method_one)[:params]
  end
end