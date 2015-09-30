# The main class for all the Minecraft Server Api functions
class KWApi < Sinatra::Base
  set :token, ENV['SERVER_UNIQUE_KEY']

  get '/user/:game/:name' do
    my_hash = { game: game, name: name }
    json = JSON.generate(my_hash)
    "Hello #{params['name']}, you are in #{params['game']}! The JSON String "\
    "looks like that: #{json}"
  end

  # Api for The Minecraft Server play.kwstudios.org
  post '/minecraft/server/:server/players/:player/storedata/:data' do
    if !valid_request?
      puts "Invalid payload request for server #{params[:server]}"
    else
      data = JSON.parse(params[:data])

      name = data['name']
      first_played = Time.at(data['first_played'] / 1000)
      last_played = Time.at(data['last_played'] / 1000)
      is_online = data['is_online']
      is_banned = data['is_banned']

      players = Players.first_or_create(uuid: "#{data['uuid']}")
      players.name = name
      players.server = params[:server]
      players.first_played = first_played
      players.last_played = last_played
      players.is_online = is_online
      players.is_banned = is_banned
      players.save

      puts 'Authenticated successfully!'
      puts 'Welcome, KWStudios!'
      puts "Changing stuff on #{params[:server]} server"
      puts "Received valid payload for server #{params[:server]}"
    end
  end

  def valid_request?(server)
    digest = Digest::SHA2.new.update("#{server}#{settings.token}")
    digest.to_s == authorization
  end

  def authorization
    env['HTTP_AUTHORIZATION']
  end
end
