# The main class for the WalkMyDog geocoding route
class KWApi < Sinatra::Base
  post '/walkmydog/users/geocoding/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])
    status 200

    login_success_json_string = profile.gmresponse.to_json

    content_type 'application/json'
    login_success_json_string
  end
end
