# The main class for error handling
class KWApi < Sinatra::Base
  not_found do
    json_hash = { message: 'Not Found' }
    json_string = JSON.generate(json_hash)

    content_type 'application/json'
    json_string
  end
end
