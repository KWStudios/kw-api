# The main class for logging in as a fb user
class KWApi < Sinatra::Base
  post '/stars/v1/fb/login/?' do
    id = params[:id]
    token = params[:token]

    check_fb_registration(id)
    verify_fb_login(id, token)

    fbuser = Fbstarsprofile.get(id)

    status 200

    register_fb_success_json_string = get_fb_stars_profile_json_string(fbuser)

    content_type 'application/json'
    register_fb_success_json_string
  end
end
