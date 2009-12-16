require 'yaml'
require 'erb'
require 'RedCloth'

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

  def get_content
    @object_hash[:content]
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

  def edit_table
    text = @object_hash[:content]
    template = get_template("fixture_table_edit.html.erb")
    rhtml = ERB.new(template)
    rhtml.result(get_binding)
  end

  def add_table_row(index)
    #Create a new blank array to insert
    row = Array.new
    0.upto(@object_hash[:content][0].size - 1){|i| row << " "}
    @object_hash[:content].insert(index,row)
    template = get_template("fixture_table_edit.html.erb")
    rhtml = ERB.new(template)
    rhtml.result(get_binding)
  end

  def delete_table_row(index)
    @object_hash[:content].delete_at(index)
    template = get_template("fixture_table_edit.html.erb")
    rhtml = ERB.new(template)
    rhtml.result(get_binding)
  end

  #this uses RedCloth to Textile-ize the text in the text areas.  It should be stored with the
  #textile markup (or is it markdown?) embedded in the text.  It will only be converted on its
  #way out to the browser.
  def create_text
    @content = @object_hash[:content]
    @content = RedCloth.new(@content).to_html
    template = get_template("text_element.html.erb")
    rhtml = ERB.new(template)
    rhtml.result(get_binding)
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