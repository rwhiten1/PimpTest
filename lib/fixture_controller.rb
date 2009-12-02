require File.dirname(__FILE__) + "/test_page"
require File.dirname(__FILE__) + "/controllers"
require File.dirname(__FILE__) + "/parse_fixture"
require 'erb'
require 'rack'
require 'yaml'

#This file contains the controller that is responsible for
#managing HTTP interactions with the Fixture Repository/Manager.
#The main purpose of this particular controller will be to handle
#HTTP file uploads of new fixture files.  Additionally, when a fixture
#is added to a test page from the repository, this controller will
#ensure communicate with the fixture repository to retrieve the
#proper HTML skeleton for the web page
#Author:: Rob Whitener
module Controllers
  class FixtureController
    def initialize(app=nil)
      if app
        @app = app
        puts @app.inspect
      else
        @app = self
      end
      root_dir
      @parser = nil
    end
    
    #call method is required by the Rack Spec
    def call(env)
      puts "\n-----------------------------------------------------------------------\n"
      env.each do |k,v|
        puts "#{k} => #{v}"
      end
       puts "\n-----------------------------------------------------------------------\n"
       req = Rack::Request.new(env)
       return store_file(req,env)
       #[200,{"Content-Type"=>"text/html"},"A file has been uploaded"]
    end
    
    def store_file(req,env)
      puts "\t**************Form Data******************"
      #just print out what parmeters are there for now
      info = req.params["file_info"]
      info.each { |k,v| puts "\t#{k} => #{v}"  }

      #write the file data to a new ruby file under the fixtures directory
      puts "\tCurrent Directory:  #{Dir.pwd}\n\t Filename: #{info[:filename]}"
      File.open(Dir.pwd + "/fixtures/#{info[:filename]}", "w") do |file|
        while line = info[:tempfile].gets
          file.write(line.rstrip + "\n")
        end
      end
      
      #rewind the temp file and pass it to the fixture parser
      info[:tempfile].close
      parser = FixtureParser.new(info[:filename])
      parser.parse_file
      parser.build_meta_information
      
      #go back to the home page for now
      resp = Rack::Response.new("Redirecting....")
      resp.redirect("/HomePage")
      resp.finish
    end 
    
  end
end