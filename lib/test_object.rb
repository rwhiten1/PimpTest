require 'yaml'
require 'erb'

class TestObject

  def initialize(location)
    #find the root of the test page tree
    current = Dir.pwd
    Dir.chdir("../config")
    config = YAML::load(File.open("config.yml"))
    root_dir = config[:root_dir]
    Dir.chdir(current)  
    #load the yaml object file
    @object_hash = YAML::load(File.open(File.dirname(__FILE__) + File::SEPARATOR + root_dir+ File::SEPARATOR + location + ".yml"))
    @object_hash[:name] = location.split("\/").last

  end

  def component_type
    @object_hash[:type]
  end

  def get_name
    @object_hash[:name]
  end

  def to_html
    #need to generate html based on what the component type is
    self.send("create_#{component_type}".to_s)
  end

  def create_table
    text = @object_hash[:content]
    template = get_template("fixture_table.html.erb")
    rhtml = ERB.new(template)
    rhtml.result(get_binding)
  end

  def create_text
    text = @object_hash[:content]
    #replace all newlines with <br> tags
    text.gsub!("\n","<br/>")
    #wrap it in a paragraph tag.
    text = "<p>#{text}</p>"
  end

  private

  def get_binding
    binding
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

end