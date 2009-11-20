#This is a fake fixture class, meant to help test out the
#Fixture repository code (the code that incorporates Fixtures into
#the testing system
#Author:: Rob Whitener
#Copyright:: Copyright (c) 2009
#License:: Ruby License
class FakeFixtureClass

  attr_accessor :var1, :var2, :var3, :var4

  def initialize
    @var1 = ""
    @var2 = ""
    @var3 = ""
    @var4 = ""
  end

  #Fake Fixture Method 1.
  #This basically just prints out some values.  If the method really
  #did something special it would be documented here
  #params:: @var1 @var2
  #type:: table
  #----
  #Format:
  # |var1|var4|fake_method_one|
  # |data1|data4|expected result|
  def fake_method_one()
    #the parameters used in this method should all be instance variables
    puts "variable 1 => #{@var1}"
    puts "variable 4 => #{@var4}"
  end

  #Fake Fixture Method 2.
  #This basically just prints out some values.  If the method really
  #did something special it would be documented here
  #params:: @var1 @var2
  #----
  #Table Format:
  # |var2|var3|fake_method_one|
  # |data2|data3|expected result|
  def fake_method_two()
    #the parameters used in this method should all be instance variables
    puts "variable 2 => #{@var2}"
    puts "variable 3 => #{@var3}"
  end
end
