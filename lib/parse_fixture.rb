class FixtureParser

  attr_reader :comments

  def initialize(file)
    @filename = file
    @class = ""
    @methods = Hash.new
    @block_count = 0 #this will help keep track of block level elements inside method bodies
    @passed_def = false
    load_file
  end

  def get_class
    #right now, this will only handle files with one class in them
    #later, I will expand it to handle multiple classes in one file.
    if @class == "" then
      @file_data.each do |line|
        if line =~ /^class\s+(.*)<{0,1}/ then
          @class = $1
        end
      end
    end

    @class
  end

    def get_methods
      if @methods.size == 0 then
        @file_data.each do |line|
          if line =~/^\s+def\s+(.+)\(/ then
            @methods[$1.to_sym] = nil
          end
        end
      end

      @methods
    end

  def parse_file
    get_class #pull out the class name
    get_methods #put the method names into a hash
    #now, loop over each line in the file
    @comments = Hash.new
    in_comment = false
    comment_block = Array.new
    @file_data.each_with_index do |line,i|
       if line =~ /^\s*#/ then #is it a hash mark (#)?
         #is this a new comment block? if it isn't clean out the block
         comment_block << line.gsub(/\s*#/,"") if !in_method?(line)#get rid of the hash mark and any leading spaces
         in_comment = true
       elsif line =~ /#{@class}/
         # we are on the class definition line, associate the previous comment block with the class name
         @comments[@class.to_sym] = comment_block
         in_comment = false
         in_class = true
         comment_block = Array.new
       elsif line =~ /^\s+def\s+(.+)\(/
         #this is the method line, associate the comment with the matching method name
         @comments[$1.to_sym] = comment_block
         in_comment = false
         comment_block = Array.new
       end
    end
    i = 0
  end

  #After parsing the file to extract all the comments,
  #This method must be called to pull the meta data out from the comments
  #and associate the meta data with a fixture method (or class declaration)
  #inside the meta hash.  The meta hash will be output into a yaml file with the
  #fixture's name.
  def build_meta_information
    @meta_info = Hash.new
    @comments.each do |key,comm_array|
        @meta_info[key] = parse_comment(comm_array)
    end

    puts "build_meta_information: dir? = #{Dir.pwd}"
    yaml_file = @filename.gsub("rb","yml")
    File.open(Dir.pwd + "/fixtures/" + yaml_file,'w') do |io|
      YAML.dump(@meta_info,io)
    end
  end

  #this method takes a symbol for a fixture method (or class definition)
  #and returns the meta hash for that item
  def get_meta_info(key)
    @meta_info[key]    
  end

  #in_method? accepts a line of text and tries to determine if the line
  #is part of a method body or not.  To do this, it keeps track of the number of
  #block elements (if, while,case, do, etc.) that it has encountered during processing
  #as well as whether or not it has passed a 'def' statement.  The block counter will
  #be incremented each time a block element is found, and decremented each time an 'end' statement
  #is encountered. If @passed_def = true, an end statement is encountered, and block_count = 0, then
  #the end of the method has been found.
  def in_method?(line)
    in_a_method = false
    if line =~ /^\s*def/
       in_a_method =true
       @passed_def = true
    elsif line =~ /^\s*(if|while|for|until|case|unless)/ || line =~ /^\s*.*do\s+/ then
      #we are in a block, inside the method
      @block_count += 1
      in_a_method = true
    elsif line =~ /^\s*end/ then
      #we reached the end of a block
      if @block_count >= 1 then
        @block_count -= 1
        in_a_method = true
      else #block_count == 0
        @passed_def = false
        in_a_method = false
      end
    else
      #this line isn't block level, isn't a method definition, and isn't an end statement
      if @passed_def then
        in_a_method = true
      end
    end
    in_a_method
  end

  #parse_comment accepts an array of strings that compose a continous comment for either a class
  #or method.  It will pull out the relevant pieces of information, put them into a hash, then
  #return that hash.
  #Looking for:
  #*type: the type of fixture method this is (ie. table)
  #*format: the format that will be used to render an empty instance of the fixture method in HTML
  #*params: the instance variables that are used by this method
  #Anything not denoted by one of these headings is considered info.  Info should be the very first text in the fixture
  #comments, and format should be the very last, the order of params and type doesn't matter
  def parse_comment(comment_array)
    meta_info = {:info => "",:params => "", :type => "", :format => ""}
    in_format = false
    in_info = true
    comment_array.each do |line|
      #look at the beginning of each line to determing what it is
      if line =~ /^params/ then
        #parameters definition
        params = line.split("::")[1].strip
        meta_info[:params] = params.split(" ")
        in_info = false
      elsif line =~ /^type/ then
        #fixture method type
        meta_info[:type] = line.split("::")[1].strip
        in_info = false
      elsif line =~ /^format/ then
        #format of the fixture
        in_format = true #just set in_format to true, the acutal format starts on the next line
        in_info = false
      else
        #test to see if this is part of the format
        if !in_format then
          meta_info[:info] += "#{line}\n" if in_info
        else
          line.strip!
          meta_info[:format] += "#{line}\n"
        end
      end
    end
    meta_info[:format].strip!
    meta_info
  end

  private
  def load_file
    @file_data = Array.new
    puts "Now we are in: #{Dir.pwd}"
    File.open(Dir.pwd + "/fixtures/" + @filename) do |file|
      while line = file.gets
        @file_data << line.gsub!("\n","")
      end
    end
  end

end