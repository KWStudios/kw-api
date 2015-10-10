# The main class for error handling
class KWApi < Sinatra::Base
  not_found do
    json_hash = { message: 'Not Found', status: 404 }
    json_string = JSON.generate(json_hash)

    content_type 'application/json'
    json_string
  end
end
