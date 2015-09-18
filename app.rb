require 'sinatra'
require 'data_mapper'
require 'tilt/haml'
require 'json'
require 'digest/sha2'

dbFile = open("json/db.json")
dbJson = dbFile.read
db = JSON.parse(dbJson)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://#{db['username']}:#{db['password']}@#{db['hostname']}/#{db['database']}")

class Version
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :version,      String
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
      version = Version.first_or_create(:name => "#{repo_slug.downcase}")
      version.version = number
      version.completed_at = Time.now
      version.save
      puts "Authenticated successfully!"
      puts "Welcome, TravisCI!"
      puts "Changing stuff on KWStudios/RageMode repo_slug"
      puts "Received valid payload for repository #{repo_slug}"
    end
  end

  def valid_request?
    digest = Digest::SHA2.new.update("#{repo_slug}#{settings.token}")
    digest.to_s == authorization
  end

  def authorization
    env['HTTP_AUTHORIZATION']
  end

  def repo_slug
    env['HTTP_TRAVIS_REPO_SLUG']
  end

  get '/plugins/:user/:repo/versions/newest' do
    version = Version.first_or_create(:name => "#{params[:user].downcase}/#{params[:repo].downcase}")
    if version.version.nil?
      "This api has not any data stored yet :/"
    else
      updaterFile = open("json/#{params[:repo].downcase}.json")
      updaterJson = updaterFile.read
      updater = JSON.parse(updaterJson)
      redirect to("http://storage.googleapis.com/play-kwstudios-org/#{params[:repo].downcase}/travis-builds/#{version.version}/#{params[:repo].downcase}-#{updater['VERSION']}.jar")
    end
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
