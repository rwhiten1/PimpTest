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

end