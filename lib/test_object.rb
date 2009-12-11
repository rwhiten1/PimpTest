require 'yaml'
require 'erb'

class TestObject

  def initialize(table)
    #find the root of the test page tree
    @object_hash = table

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

  def create_heading
    template = get_template("content_heading.html.erb")
    rhtml = ERB.new(template)
    rhtml.result(get_binding)
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