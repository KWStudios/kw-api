# The main class for all the Minecraft Server Api functions
class KWApi < Sinatra::Base
  set :server_unique_token, ENV['SERVER_UNIQUE_KEY']

  get '/user/:game/:name/?' do
    my_hash = { game: params[:game], name: params[:name] }
    json = JSON.generate(my_hash)
    "Hello #{params['name']}, you are in #{params['game']}! The JSON String "\
    "looks like that: #{json}"
  end

  # Storedata function for players on a specific server
  post '/minecraft/server/:server/players/:player/storedata/?' do
    if !valid_minecraft_request?(params[:server].downcase)
      puts "Invalid payload request for server #{params[:server]}"
      status 401
    else
      data = JSON.parse(params[:data])

      name = data['name']
      uuid = data['uuid']
      first_played = Time.at(data['first_played'] / 1000)
      last_played = Time.at(data['last_played'] / 1000)
      is_online = data['is_online']
      is_banned = data['is_banned']

      players = Players.first_or_create(uuid: uuid)
      players.name = name
      players.server = params[:server].downcase
      players.first_played = first_played
      players.last_played = last_played
      players.is_online = is_online
      players.is_banned = is_banned
      players.save

      puts 'Authenticated successfully!'
      puts 'Welcome, KWStudios!'
      puts "Changing stuff on #{params[:server]} server"
      puts "Received valid payload for server #{params[:server]}"

      json_hash = { name: name, uuid: uuid, first_played: first_played,
                    last_played: last_played, is_online: is_online,
                    is_banned: is_banned }
      json_string = JSON.generate(json_hash)

      content_type 'application/json'
      json_string
    end
  end

  def valid_minecraft_request?(server)
    digest = Digest::SHA2.new.update("#{server}#{settings.server_unique_token}")
    digest.to_s == authorization_code
  end

  def authorization_code
    env['HTTP_AUTHORIZATION_CODE']
  end

  # The get method for players (Simple minecraft server api)
  get '/minecraft/server/:server/players/:player/?' do
    players = Players.first(name: params['player'])

    if !players.nil?
      name = players.name
      uuid = players.uuid
      first_played = players.first_played
      last_played = players.last_played
      is_online = players.is_online
      is_banned = players.is_banned
    else
      status 204
    end
    json_hash = { name: name, uuid: uuid, first_played: first_played,
                  last_played: last_played, is_online: is_online,
                  is_banned: is_banned }
    json_string = JSON.generate(json_hash)

    content_type 'application/json'
    json_string
  end
end
