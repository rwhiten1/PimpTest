%w(rubygems rack mywebapp).each { |dep| require dep}
app = MyWebApp.new #lambda { |env| sleep(5);[200,{},'My First Rack App']}
Rack::Handler::Mongrel.run(app, :Port=>3000)