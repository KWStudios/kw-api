# The main class for all the Minecraft Server Api functions
class KWApi < Sinatra::Base
  get '/user/:game/:name' do
    "Hello #{params['name']}, you are in #{params['game']}!"
  end

  # Api for The Minecraft Server play.kwstudios.org
  post '/minecraft/server/:server/:player/storedata/:data' do
    'Arrr, this should be the Main method code!'
  end
end
