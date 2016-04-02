# The main class for registering as a fb user
class KWApi < Sinatra::Base
  # This happens if a user registers as a fb user
  post '/stars/v1/fb/register/?' do
    id = params[:id]
    token = params[:token]

    unless Fbstarsprofile.count(id: id) == 0
      register_error_json_hash = {
        message: 'This Email address already exists', error: 409 }
      register_error_json_string = JSON.generate(register_error_json_hash)

      halt 409, { 'Content-Type' => 'application/json' },
           register_error_json_string
    end

    verify_fb_login(id, token)

    payload = params[:payload]
    check_payload(payload)
    check_json(payload)
    json = JSON.parse(payload)

    name = json['name']
    first_name = json['first_name']
    last_name = json['last_name']
    link = json['link']
    gender = json['gender']
    locale = json['locale']
    timezone = json['timezone']
    updated_time = json['updated_time']
    verified = json['verified']
    email = json['email']

    fbuser = Fbstarsprofile.new

    fbuser.id = id
    fbuser.name = name
    fbuser.first_name = first_name
    fbuser.last_name = last_name
    fbuser.link = link
    fbuser.gender = gender
    fbuser.locale = locale
    fbuser.timezone = timezone
    fbuser.updated_time = updated_time
    fbuser.verified = verified
    fbuser.email = email

    unless fbuser.saved?
      register_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      register_error_json_string = JSON.generate(register_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           register_error_json_string
    end

    status 200

    register_fb_success_json_string = get_fb_stars_profile_json_string(fbuser)

    content_type 'application/json'
    register_fb_success_json_string
  end
end
