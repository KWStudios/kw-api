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
