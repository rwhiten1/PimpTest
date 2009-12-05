require File.dirname(__FILE__) + "/test_object"
require "fileutils"
class TestPage

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
    @order = @page[:order]
    @order.each_with_index do |o,i|
      component = TestObject.new(@page[o.to_sym])
      content += "<div class=\"#{component.component_type}\ black-border\" id=\"#{o}\">\n#{component.to_html}\n</div>\n"
      if i < @order.size - 1 then
        content += "<br/>\n"
      end
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

end