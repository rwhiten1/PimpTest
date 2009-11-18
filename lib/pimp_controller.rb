require File.dirname(__FILE__) + "/test_page"
require 'erb'
require 'rack'


  class PimpController

    def initialize(app=nil)
      if app
        @app = app
        puts @app.inspect
      else
        @app = self
      end

    end

    def call(env)
      puts "\n-----------------------------------------------------------------------\n"
      env.each do |k,v|
        puts "#{k} => #{v}"
      end
       puts "\n-----------------------------------------------------------------------\n"
      path = env["REQUEST_PATH"]
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
      #first, construct the page
      puts "LOOKING FOR URL: #{url}"
      #return Rack::Response.new("No Favicon Available",404) if url =~ /favicon/
      page = TestPage.new(url)
      @html = page.generate
      @page_list = page.get_child_list
      #now, look up the template and read it into a string
      layout = ""
      puts "We are in: #{Dir.pwd}"
      File.open(Dir.pwd + "/public/layout/main_layout.html.erb") do |file|
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
  end
