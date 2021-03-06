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
        req = Rack::Request.new(env)
         puts "\n\t+++++++++++++++++++++++++++++++++++++++++++++"
        puts "\n\tRequest parameters:"
        req.params.each {|k,v| puts "\n\t#{k} => #{v}"}
        puts "\n\t+++++++++++++++++++++++++++++++++++++++++++++"

        #run an action based on the request path.  If the request path doesn't contain
        #a public method, then it will defualt to executing the render method.
        html = run_action(req,env)

        if html != "" then
          puts "\t>>>>>HTML chunk is non-empty, passing back to the client....."
          resp = Rack::Response.new()
          resp.write(html)
          resp.finish
        else
          puts "\n\tRendering Request Path: #{env["REQUEST_PATH"]}"
          render(env["REQUEST_PATH"])
        end

      else        
        resp = Rack::Response.new("Redirecting....")
        resp.redirect("/HomePage")
        resp.finish
      end

    end


    #this method will look for an action method name that matches part of the
    #request path
    def run_action(req,env)
      #loop over the public instance methods, looking for an action
      html = ""
      self.public_methods.each do |method|
        if @location =~ /#{method}$/ then
          puts "\n\tRequest Path: #{@location}\n\tMethod Name: #{method}"
          #we found the method, call it and pass in the request and the environment
          html = self.send(method.to_sym,req,env)
          break
        end
      end
      html
    end

    #Render is the default action executed if another action belonging
    #to the controller isn't specifically named in the URL
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


    #
    #Actions go here.
    #Actions must explicity accept two arguments.  The first argument is the current HTTP request being handled
    #by the applicaiton.  The second argument is the environment array produced by Rack.  An action must return
    #a String containing an HTML fragment or other data acceptable to the HTTP request agent.
    #
    def add_fixture(req,env)
      h = Hash.new
      h[:name] = req.params["fixture"]
      h[:method] = req.params["method"]
      h[:position] = req.params["position"] == "last" ? req.params["position"].to_sym : req.params["position"]
      h[:path] = "/"+@location[0...@location.size-12] #strip off the add_fixture part of the path
      page = TestPage.new(h[:path])
      html = page.add_fixture(h)
    end

    #this method basically returns HTML to replace the current HTML on the page.  The replacement will
    #contain a form where each text field represents a cell (with that cell's value), as well
    #as buttons to insert rows (should probably be buttons to delete rows.
    def edit_table(req,env)
      h = {:name => req.params["element"], :path => @location[0...@location.size - 11]}
      if !@location.match(/^\//) then
        h[:path] = "/" + h[:path]
      end
      page = TestPage.new(h[:path])
      html = page.edit_table(h)
    end

    #this method will add a blank row to the table being edited.
    def add_table_row(req,env)
      h = {:name => req.params["element"],
           :index => req["index"].to_i,
           :path => @location[0...@location.size - 14]}
      if !@location.match(/^\//) then
        h[:path] = "/" + h[:path]
      end
      page = TestPage.new(h[:path])
      html = page.add_table_row(h)
    end

    #this method deletes a table row
    def delete_table_row(req,env)
      h = {:name => req.params["element"],
           :index => req["index"].to_i,
           :path => @location[0...@location.size - 16]}
      fix_path(h)
      page = TestPage.new(h[:path])
      html = page.delete_table_row(h)
    end

    #this method "cancels" the edit by just retrieving the table, but in its non-editable form
    def cancel_edit(req,env)
      h = {:name => req.params["element"],
           :path => @location[0...@location.size - 12]}
      fix_path(h)
      page = TestPage.new(h[:path])
      html = page.get_table(h)
    end

    #this method parses the table fields out of the request, wraps them up into an array,
    #and then passes the array of to the TestPage so that it can save the table.
    def save_table(req,env)

      rows = req["rows"].to_i
      cols = req["cols"].to_i
      #build the array
      table = Array.new
      0.upto(rows - 1) do |i|
        row = Array.new
        0.upto(cols - 1) do |j|
          row[j] = req["row_#{i}_col_#{j}"]
        end
        table[i] = row
      end

      h = {:name => req["element"],
           :content => table,
           :path => @location[0...@location.size - 11]}

      if !@location.match(/^\//) then
        h[:path] = "/" + h[:path]
      end

      page = TestPage.new(h[:path])
      html = page.save_table(h)
      html
    end

    def add_text(req,env)
      h = Hash.new
      h[:text] = req.params["text"]
      h[:after] = req.params["after"]
      h[:path] = @location[0...@location.size-9]
      if !@location.match(/^\//) then
        h[:path] = "/" + h[:path]
      end
      h[:type] = :text
      page = TestPage.new(h[:path])
      html = page.add_element(h)
      html
    end

    def add_header(req,env)
      h = Hash.new
      h[:header] = req.params["header"]
      h[:after] = req.params["after"]
      h[:size] = req.params["size"]
      h[:path] = @location[0...@location.size-11]
      if !@location.match(/^\//) then
        h[:path] = "/" + h[:path]
      end
      h[:type] = :heading
      page = TestPage.new(h[:path])
      html = page.add_element(h)
      html
    end

    def edit_header(req,env)
      h = Hash.new
      h[:header] = req.params["header"]
      h[:name]  = req.params["elem"]
      h[:path] = @location[0...@location.size-12]
      page = TestPage.new(h[:path])
      html = page.edit_header(h)
      html
    end

    def get_unformated_text(req,env)
      h = {:name => req.params["elem"], :path => @location[0...@location.size - 20]}
      #fix_path(h)
      page = TestPage.new(h[:path])
      page.get_element_content(h[:name].to_sym)
    end

    def edit_text(req,env)
      h = Hash.new
      h[:text] = req.params["text"]
      h[:name] = req.params["elem"]
      h[:path] = @location[0...@location.size-10]
      page = TestPage.new(h[:path])
      html = page.edit_text(h)
      html
    end

    def delete_element(request, env)
      #pull out the params
      h = {:element => request.params["element"]}
      h[:path] = @location[0...@location.size-15]
      page = TestPage.new(h[:path])
      page.delete_element(h)
      html = "deleted"
      #html = page.generate
      #if html == "" then
      #  #this is an exception, and should be handled a little better.
      #  html = "<p>Don't be a suckah, put some content on the page playa!</p>"
      #end
      #html
    end

    def add_page(req,env)
      h = {:name => req.params["page_name"]}
      @location = @location[0...@location.size-9]
      h[:path] = @location
      page = TestPage.new(h[:path])
      page.add_child(h)
      #need to remove the "add_page" from the request path
      env["REQUEST_PATH"] = "/"+ @location
      html = ""
      html
    end



    #
    #View helper methods.
    # These methods are executed when the layout template is being rendered.

    #This method will render a template for breadcrumbing.  It will look for a template named
    #breadcrumb.html.erb in the lib/templates directory.  This will be the convention for any other templates
    #that will be rendered - the method that renders the template will share a name with the template file.
    def breadcrumb()
      #look up the template file
      puts Dir.pwd
      process_template("breadcrumb.html.erb"){ @names = @location.split(/\//) }
    end

    #This method will look up each "fixture" YAML file in the fixtures directory and load each YAML
    #as a sub hash into a hash with the key being the fixtures class name.  Each YAML file in the
    #fixtures directory contains a hash of methods in that fixture, the keys are the method names
    def fixtures()
     #grab the fixtures
      current = Dir.pwd
      rhtml = process_template("fixture_repository.html.erb") do
         puts "Current directory: #{Dir.pwd}"
        Dir.chdir("fixtures") #change to the fixtures directory
        @fixtures = Hash.new
        Dir.glob("*.yml") do |name|
          h = YAML::load(File.open(name))
          @fixtures[name[0...name.size-4].to_sym] = h
        end
      end
      Dir.chdir(current)
      rhtml
    end

    def get_binding
      binding
    end

    private


    def process_template(template)
      template = get_template(template)
      yield
      rhtml = ERB.new(template)
      rhtml.result(get_binding)
    end

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

    def fix_path(h)
      if !@location.match(/^\//) then
        h[:path] = "/" + h[:path]
      end
    end

    
  end
end
