require 'sinatra'
require 'data_mapper'
require 'tilt/haml'
require 'json'
require 'digest/sha2'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/versions.db")

class Version
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :completed_at, DateTime
end
DataMapper.finalize

class TravisWebhook < Sinatra::Base
  set :token, ENV['TRAVIS_USER_TOKEN']

  post '/travis/webhooks/RageMode' do
    if not valid_request?
      puts "Invalid payload request for repository #{repo_slug}"
    else
      payload = JSON.parse(params[:payload])
      number = payload['number']
      version = Version.new(:name => number)
      version.save
      puts "Received valid payload for repository #{repo_slug}"
    end
  end

  def valid_request?
    digest = Digest::SHA2.new.update("#{repo_slug}#{settings.token}")
    puts "Authenticated successfully!"
    puts "Welcome, TravisCI!"
    puts "Changing stuff on KWStudios/RageMode repo_slug"
    digest.to_s == authorization
  end

  def authorization
    env['HTTP_AUTHORIZATION']
  end

  def repo_slug
    env['HTTP_TRAVIS_REPO_SLUG']
  end


  get '/' do
    @tasks = Version.all
    haml :index
  end

  post '/' do
    Version.create  params[:task]
    redirect to('/')
  end

  post '/task/:id' do
    if params[:_method] == "delete"
      Version.get(params[:id]).destroy
      redirect to('/')
    else
      version = Version.get params[:id]
      version.completed_at = version.completed_at.nil? ? Time.now : nil
      version.save
      redirect to('/')
    end
  end

  get '/user/:game/:name' do
    "Hello #{params['name']}, you are in #{params['game']}!"
  end
end
