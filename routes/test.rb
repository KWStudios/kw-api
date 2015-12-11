# The main class for the TravisWebhook
class KWApi < Sinatra::Base
  post '/test' do
    title = 'Haml Test'
    haml :test
  end
end
