require 'sinatra'
require 'tilt/haml'
require 'json'
require 'digest/sha2'
require 'open-uri'

# The main class for the kw-api
class KWApi < Sinatra::Base
  enable :sessions

  configure :production do
    set :haml, ugly: true
    set :clean_trace, true
  end

  configure :development do
    # ...
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
