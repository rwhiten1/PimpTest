require File.dirname(__FILE__) + "/test_object"
require "fileutils"
class TestPage
  attr_reader :page
  def initialize(location)
    current = Dir.pwd()
    Dir.chdir("../config")
    config = YAML::load(File.open("config.yml"))
    @root_dir = config[:root_dir]
    Dir.chdir(current)
    @location = location
    #get the order.yml file out of the page's directory
    @page = YAML::load(File.open(File.dirname(__FILE__) + File::SEPARATOR + @root_dir+ File::SEPARATOR + location + File::SEPARATOR + "page.yml"))

  end

  def generate
    #loop over the order array
    content = ""
    template = get_template("page_element.html.erb");
    @order = @page[:order]
    @order.each_with_index do |o,i|
      puts "Rendering page element: #{o}"
      @component = TestObject.new(@page[o.to_sym])
      rhtml = ERB.new(template);
      content += rhtml.result(get_binding)
      #if i < @order.size - 1 then
      #  content += "<br/>\n"
      #end
    end
    content
  end

  def get_child_list
    #need to make sure we are in the correct location
    puts "CurrentDirecory:  #{Dir.pwd}"
    current = Dir.pwd
    Dir.chdir(@root_dir + File::SEPARATOR + @location)
    puts "Current Direcory Now:  #{Dir.pwd}"
    html = "<h4>Pages</h4>\n"
    html += "<ul class=\"child_pages\">"
    #iterate over the files
    Dir.glob("*") do |file|
      if File.directory?(file) then
        #add it to the list
        html += "<li><a href=\"#{@location}/#{file}\">#{file}</a></li>\n"
      end
    end
    html += "</ul>"
    Dir.chdir(current) #change back to the original directory
    html
  end

  def add_child(page)
    puts "CurrentDirectory: #{Dir.pwd}"
    current = Dir.pwd
    Dir.chdir(Dir.pwd + File::SEPARATOR + @location)
    FileUtils.mkdir(page[:name])
    Dir.chdir(page[:name])
    h = {:order => []}
    #FileUtils.touch("page.yml")
    File.open("page.yml","w") do |io|
      YAML::dump(h,io)
    end
    Dir.chdir(current)
  end

  def add_fixture(fix)
    #grab out the fixture name and method, turn the name into a yaml filename
    fixture_file = fix[:name] + ".yml"
    fixture_method = fix[:method].to_sym
    fixture = YAML::load(File.open(Dir.pwd + "/fixtures/" + fixture_file))
    new_fixture = {:type => fixture[fixture_method][:type],
                   :class => fix[:name],
                   :content => fixture[fixture_method][:format]}

    #now, determine how to name this thing, load the order array
    order = @page[:order]
    #find all instances in the order array (order.yml)
    types = order.select {|e| e =~ /#{new_fixture[:type]}/}

    #get the position
    if fix[:position] == :last then
      order << new_fixture[:type] + "_#{types.size + 1}"
    else
      0.upto(fix[:position].to_i - 1) { |i| new_order << order[i]; pos += 1}
      #insert the new element
      new_order << new_fixture[:type] + "_#{types.size + 1}"
      fix[:position].to_i.upto(order.size - 1) { |i| new_order << order[i]}
      order = new_order
    end

    #put the name into the new fixture
    new_fixture[:name] =  "#{new_fixture[:type]}_#{types.size + 1}"

    #add the new fixture to the page
    @page["#{new_fixture[:type]}_#{types.size + 1}".to_sym] = new_fixture
    #@page[:order] = order

    #now, dump the two collections out to files
    File.open(Dir.pwd + fix[:path] + "/page.yml", "w") do |io|
      YAML::dump(@page,io)
    end

    #now, create an HTML version of the new fixture and return that
    html = "<div class=\"#{new_fixture[:type]}\ black-border\" id=\"#{new_fixture[:type]}_#{types.size + 1}\">"
    html += TestObject.new(new_fixture).to_html
    html += "</div>"
  end

  #This method adds a vanilla element to the page.  Its either going to be
  #a block of text, a header, or a blank table (with no associated fixture)
  def add_element(info)
    #get what type of element it is
    puts "Adding element of type :#{info[:type].to_s}"
    if info[:type] == :text then
      add_text_element(info)
    elsif info[:type] == :heading then
      add_header_element(info)
    elsif info[:type] == :table then
      add_table_element(info)
    end
  end

  #this method adds a new text block to the page.  Its awesome!
  def add_text_element(info)
    #first, find out where to insert the text element
    position = @page[:order].index(info[:after]) + 1 #put it right 'after' that one
    #count up the number of text elements
    text_elems = @page[:order].select {|e| e =~ /text/}
    @page[:order].insert(position,"text_#{text_elems.size+1}")

    #now, add the text to the page hash
    new_text = {:type => "text",
                :name => "text_#{text_elems.size+1}",
                :content => info[:text]}
    @page["text_#{text_elems.size+1}".to_sym] = new_text

    #and save the yaml file
    File.open(Dir.pwd + File::SEPARATOR + @location + "/page.yml", "w") do |io|
      YAML::dump(@page,io)
    end

    #generate the HTML and return it to the browser
    template = get_template("page_element.html.erb");
    @component = TestObject.new(@page["text_#{text_elems.size+1}".to_sym])
    rhtml = ERB.new(template);
    rhtml.result(get_binding)
  end

  #this method adds a header to the page and then returns the HTML containing the header
  #so it may be displayed on the page
  def add_header_element(info)
    #first, find out where to insert the element <-- Candidate section for a refactor
    position = @page[:order].index(info[:after]) + 1
    #get an array of already present headers
    head_elems = @page[:order].select{|e| e =~ /head/}
    #insert into the order array
    @page[:order].insert(position,"head_#{head_elems.size+1}")


    #now, add the page to the hash
    new_header = {:type => "heading",
                  :name => "head_#{head_elems.size+1}",
                  :size => info[:size],
                  :content => info[:header]}
    @page["head_#{head_elems.size+1}".to_sym] = new_header


    #save the yaml file <-- Candidate section for a refactor
    File.open(Dir.pwd + File::SEPARATOR + @location + "/page.yml", "w") do |io|
      YAML::dump(@page,io)
    end

    #generate the HTML and return it to the browser <-- candidate for a refactor
    template = get_template("page_element.html.erb");
    @component = TestObject.new(@page["head_#{head_elems.size+1}".to_sym])
    rhtml = ERB.new(template);
    rhtml.result(get_binding)
  end

  def delete_element(del)
     puts "In TestPage.delete_element()"
    del.each do |k,v|
      puts "#{k} => #{v}"
    end
    #grab the order array from the page hash
    order = @page[:order]
    size = order.size

    #now, remove the element from the page hash
    @page.delete(del[:element].to_sym)

    #the element yaml file is gone, now, remove its entry from the
    order.delete(del[:element])

    #now, dump the order back out to a yaml file
    File.open(Dir.pwd + File::SEPARATOR + del[:path] + "/page.yml", "w") do |io|
      YAML::dump(@page,io)
    end
  end

  #need to find a way to pull this method out into a class or method so the view related
  #classes don't need to keep repeating this.
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

  def get_binding
    binding
  end

end