require 'yaml'

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

  end

  def component_type
    @object_hash[:type]
  end

  def to_html
    #need to generate html based on what the component type is
    self.send("create_#{component_type}".to_s)
  end

  def create_table
    text = @object_hash[:content]
    #split on new lines
    rows = text.split("\n")

    html = <<H
<a class="table-button"><img  src="/images/play_button_small.png" alt="run tests"/></a>
<a class="table-button"><img src="/images/edit_small.png" alt="edit table"/></a>
<p>Fixture Class: <strong>mock_fixture</strong></p>
<table cellpadding=\"0\" cellspacing=\"0\">\n<thead>\n<tr>
H
    rows.each_with_index do |row,i|
      cells = row.split("|")
      cells.each do |c|
        html += "<td>#{c}</td>\n" if c.size > 1
      end
      if i == 0 then
        html += "</tr>\n</thead>\n<tr>\n"
      elsif i < rows.size - 1 then
        html += "</tr>\n<tr>\n"
      else
        html += "</tr>\n"
      end
    end
    html += "</table>\n"
  end

  def create_text
    text = @object_hash[:content]
    #replace all newlines with <br> tags
    text.gsub!("\n","<br/>")
    #wrap it in a paragraph tag.
    text = "<p>#{text}</p>"
  end

end