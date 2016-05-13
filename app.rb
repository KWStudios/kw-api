require 'sinatra/base'
require 'tilt/haml'
require 'json'
require 'digest/sha2'
require 'open-uri'
require 'bcrypt'
require 'net/smtp'
require 'sendgrid-ruby'
require 'data_mapper'
require 'dm-serializer'
require 'dm-types'
require 'typhoeus'
require 'fog'
require 'mime-types'
require 'uuidtools'
require 'braintree'

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

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT']
Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC']
Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE']

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
