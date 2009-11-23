#module for the controllers, will hold useful utitlity methods
module Controllers
  def root_dir
    current = Dir.pwd
    Dir.chdir("../config")
    config = YAML::load(File.open("config.yml"))
    @root_dir = config[:root_dir]
    Dir.chdir(current)
  end
end