#this is a YAML file!
#This is a file meant to be used to test the fixture meta information generator.
#The idea is to parse a fixture file one time, and pull from it the meta data
#that is necessary to provide the user with the infromation on usage and how
#tables are constructed
---
:fake_method_one:
  :type: table
  :format:
    - - var1
      - var4
      - fake_method_one
    - - data1
      - data4
      - expected result
  :info: |
    Fake Fixture Method 1.
    This basically just prints out some values.  If the method really
    did something special it would be documented here

  :params:
  - "@var1"
  - "@var4"
:fake_method_two:
  :type: table
  :format:
    - - var2
      - var3
      - fake_method_one
    - - data2
      - data3
      - expected result
  :info: |
    the parameters used in this method should all be instance variables
    Fake Fixture Method 2.
    This basically just prints out some values.  If the method really
    did something special it would be documented here

  :params:
  - "@var1"
  - "@var2"
:FakeFixtureClass: 
  :type: ""
  :format: ""
  :info: |
    This is a fake fixture class, meant to help test out the
    Fixture repository code (the code that incorporates Fixtures into
    the testing system
    Author:: Rob Whitener
    Copyright:: Copyright (c) 2009
    License:: Ruby License

  :params: ""

