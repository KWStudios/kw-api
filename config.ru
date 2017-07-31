require 'rubygems'
require 'bundler'

# Load dotenv manually so it is loaded before other gems
# and all the environment variables are already available
require 'dotenv'
Dotenv.load

Bundler.require

require File.expand_path('../app.rb', __FILE__)
use Rack::ShowExceptions
run KWApi.new
