# The main class for the TravisWebhook
class KWApi < Sinatra::Base
  get '/test' do
    @title = 'Haml Test'
    haml :test
  end
end
