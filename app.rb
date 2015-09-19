require 'sinatra'
require 'data_mapper'
require 'tilt/haml'
require 'json'
require 'digest/sha2'

db_file = open('json/db.json')
db_json = db_file.read
db = JSON.parse(db_json)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://#{db['username']}:
#{db['password']}@#{db['hostname']}/#{db['database']}")

# The Version representing database class
class Version
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, required: true
  property :version,      String
  property :completed_at, DateTime
end
DataMapper.finalize

# The main class for the TravisWebhook
class TravisWebhook < Sinatra::Base
  set :token, ENV['TRAVIS_USER_TOKEN']

  post '/travis/webhooks/RageMode' do
    if !valid_request?
      puts "Invalid payload request for repository #{repo_slug}"
    else
      payload = JSON.parse(params[:payload])
      number = payload['number']
      version = Version.first_or_create(name: "#{repo_slug.downcase}")
      version.version = number
      version.completed_at = Time.now
      version.save
      puts 'Authenticated successfully!'
      puts 'Welcome, TravisCI!'
      puts 'Changing stuff on KWStudios/RageMode repo_slug'
      puts 'Received valid payload for repository #{repo_slug}'
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
    version = Version.first_or_create(name: "#{params[:user].downcase}/
    #{params[:repo].downcase}")
    if version.version.nil?
      'This api has not any data stored yet :/'
    else
      updater_file = open("json/#{params[:repo].downcase}.json")
      updater_json = updater_file.read
      updater = JSON.parse(updater_json)
      redirect to("http://storage.googleapis.com/play-kwstudios-org/
      #{params[:repo].downcase}/travis-builds/#{version.version}/
      #{params[:repo].downcase}-#{updater['VERSION']}.jar")
    end
  end

  get '/user/:game/:name' do
    "Hello #{params['name']}, you are in #{params['game']}!"
  end
end
