require File.dirname(__FILE__) + "/test_object"
class TestPage

  def initialize(location)
    current = Dir.pwd()
    Dir.chdir("../config")
    config = YAML::load(File.open("config.yml"))
    @root_dir = config[:root_dir]
    Dir.chdir(current)
    @location = location
    #get the order.yml file out of the page's directory
    @order = YAML::load(File.open(File.dirname(__FILE__) + File::SEPARATOR + @root_dir+ File::SEPARATOR + location + File::SEPARATOR + "order.yml"))

  end

  def generate
    #loop over the order array
    content = ""
    @order.each_with_index do |o,i|
      component = TestObject.new(@location+ File::SEPARATOR + o)
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

  def add_fixture(fix)
    #grab out the fixture name and method, turn the name into a yaml filename
    puts "In TestPage.add_fixture()"
    fix.each do |k,v|
      puts "#{k} => #{v}"
    end
    fixture_file = fix[:name] + ".yml"
    fixture_method = fix[:method].to_sym
    fixture = YAML::load(File.open(Dir.pwd + "/fixtures/" + fixture_file))
    new_fixture = {:type => fixture[fixture_method][:type],
                   :class => fix[:name],
                   :content => fixture[fixture_method][:format]}

    #now, determine how to name this thing, load the order array
    order = YAML::load(File.open(Dir.pwd + fix[:path] + "/order.yml"))

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

    #now, dump the two collections out to files
    File.open(Dir.pwd + fix[:path] + "/order.yml", "w") do |io|
      YAML::dump(order,io)
    end

    File.open(Dir.pwd + fix[:path] + "/#{new_fixture[:type]}_#{types.size + 1}.yml","w") do |io|
      YAML::dump(new_fixture,io)
    end

    #now, create an HTML version of the new fixture and return that
    html = "<div class=\"#{new_fixture[:type]}\ black-border\" id=\"#{new_fixture[:type]}_#{types.size + 1}\">"
    html += TestObject.new(fix[:path][1...fix[:path].size] + File::SEPARATOR + "#{new_fixture[:type]}_#{types.size + 1}").to_html
    html += "</div>"
  end

end