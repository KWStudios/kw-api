require 'rubygems'
require 'bundler'

# Load dotenv manually so it is loaded before other gems
# and all the environment variables are already available
require 'dotenv'
Dotenv.load

# Require standard library gems
require 'base64'
require 'openssl'
require 'logger'
require 'open-uri'

Bundler.require

# The main class for the kw-api
class KWApi < Sinatra::Base
  enable :sessions

  configure :production, :development do
    enable :logging
  end

  configure :test do
    set :logging, ::Logger::ERROR
  end

  configure :production do
    set :haml, ugly: true
    set :clean_trace, true

    set :logging, ::Logger::INFO
  end

  configure :development do
    # ...
    set :logging, ::Logger::DEBUG
  end

  configure do
    # Datamapper timezone workaround
    ENV['TZ'] = 'utc'
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
