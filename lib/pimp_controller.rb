require File.dirname(__FILE__) + "/test_page"
require File.dirname(__FILE__) + "/controllers"
require 'erb'
require 'rack'

module Controllers
  class PimpController

    attr_writer :location
    attr_reader :location

    def initialize(app=nil)
      @location = nil
      if app
        @app = app
        puts @app.inspect
      else
        @app = self
      end

      #get the root dir
      root_dir

    end

    def call(env)
      puts "\n-----------------------------------------------------------------------\n"
      env.each do |k,v|
        puts "#{k} => #{v}"
      end
       puts "\n-----------------------------------------------------------------------\n"
      path = env["REQUEST_PATH"]
      @location = path[1...path.size] #make sure we save the location for any further page rendering needs
      puts "REQUEST_PATH => #{path}"
      if path != "/"
        render(env["REQUEST_PATH"])
      else        
        resp = Rack::Response.new("Redirecting....")
        resp.redirect("/HomePage")
        resp.finish
      end

    end

    def render(url)
      @location = url if !@location
      #first, construct the page
      puts "LOOKING FOR URL: #{url}"
      #return Rack::Response.new("No Favicon Available",404) if url =~ /favicon/
      page = TestPage.new(url)
      @html = page.generate
      @page_list = page.get_child_list
      #now, look up the template and read it into a string
      layout = ""
      puts "We are in: #{Dir.pwd}"
      File.open(@root_dir + "/public/layout/main_layout.html.erb") do |file|
        while line = file.gets
          layout += line
        end
      end

      #set up the layout string as an ERB template
      rhtml = ERB.new(layout)
      body = rhtml.result(self.get_binding)

      #write the page into a Rack::Response
      r = Rack::Response.new
      r.write(body)
      r.finish
    end

    def get_binding
      binding
    end

    #This method will render a template for breadcrumbing.  It will look for a template named
    #breadcrumb.html.erb in the lib/templates directory.  This will be the convention for any other templates
    #that will be rendered - the method that renders the template will share a name with the template file.
    def breadcrumb()
      #look up the template file
      puts Dir.pwd
      template = get_template("breadcrumb.html.erb")
      @names = @location.split(/\//)
      rhtml = ERB.new(template)
      rhtml.result(get_binding)
    end

    private

    def get_template(template)
      current = Dir.pwd
      #change to the lib/templates dir
      Dir.chdir("../lib/templates")
      temp_body = ""
      File.open(template,"r") do |file|
        while line = file.gets
          temp_body += line
        end
      end
      #change back to the original dir
      Dir.chdir(current)
      temp_body
    end

    
  end
end
