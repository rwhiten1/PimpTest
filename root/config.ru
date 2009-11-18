require File.dirname(__FILE__)+"/../lib/pimp_controller.rb"

root = Dir.pwd
puts ">>>>> SERVING: #{root}"

use Rack::ShowExceptions
use Rack::CommonLogger
use Rack::Static, :urls => ["/stylesheets","/images","/scripts"], :root => "public"
use PimpController
#run Rack::Directory.new("#{root}")
app = Proc.new {|env| [200,{"Content-Type" => "text/html"},["testing"]]}
run app