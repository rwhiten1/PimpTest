#!/usr/bin/ruby
require 'rubygems'
require 'rack'
require 'thin'
require File.dirname(__FILE__) + "/../lib/pimp_controller"
require File.dirname(__FILE__) + "/../lib/fixture_controller"
include Controllers
builder = Rack::Builder.new do
  use Rack::CommonLogger, STDOUT
  use Rack::ShowExceptions
  use Rack::Lint
  use Rack::Static, :urls => ["/stylesheets", "/images", "/scripts"], :root=>'public'

  
  #app = Rack::URLMap.new('/HomePage' => PimpController.new ,
  #                       '/' => Rack::File.new('favicon.ico'))
  map '/HomePage' do
    run PimpController.new
  end

  map '/favicon.ico' do
    run Rack::File.new('favicon.ico')
  end
  
  map '/fixture' do
    run FixtureController.new
  end
  
  map '/' do
    run PimpController.new
  end

  #run app
end

Rack::Handler::Thin.run builder, :Port => 3000
