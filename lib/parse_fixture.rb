class FixtureParser

  attr_reader :comments

  def initialize(file)
    @filename = file
    @class = ""
    @methods = Hash.new
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
    comment_block = ""
    @file_data.each_with_index do |line,i|
       if line[0] == "#" then
         #is this a new comment block? if it isn't clean out the block
         comment_block = "" if !in_comment
         comment_block += line[1...line.size] #get rid of the hash mark
         in_comment = true
       elsif line =~ /#{@class}/
         # we are on the class definition line, associate the previous comment block with the class name
         @comments[@class.to_sym] = comment_block
         in_comment = false
       elsif line =~ /^\s+def\s+(.+)\(/
         #this is the method line, associate the comment with the matching method name
         @comments[$1.to_sym] = comment_block
         in_comment = false
       end
    end
    i = 0
  end

  private
  def load_file
    @file_data = Array.new
    puts "Now we are in: #{Dir.pwd}"
    File.open(Dir.pwd + "/fixtures/" + @filename) do |file|
      while line = file.gets
        @file_data << line
      end
    end
  end

end