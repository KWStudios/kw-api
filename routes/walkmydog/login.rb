# The main class for the WalkMyDog login route
class KWApi < Sinatra::Base
  post '/walkmydog/users/login/?' do
    payload = JSON.parse(params[:payload])

    if payload.nil?
      login_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      login_error_json_string = JSON.generate(login_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           login_error_json_string
    end

    email = payload['email']
    password = payload['password']

    profile = Profile.get(email)
    puts "#{profile.firstname} logged in!"
  end
end
