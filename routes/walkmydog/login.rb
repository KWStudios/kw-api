# The main class for the WalkMyDog login route
class KWApi < Sinatra::Base
  post '/walkmydog/users/login/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])
    status 200

    login_success_json_string = get_profile_json_string(profile)

    content_type 'application/json'
    login_success_json_string
  end
end
