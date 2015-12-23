# The main class for the WalkMyDog add installation route
class KWApi < Sinatra::Base
  post '/walkmydog/users/installation/add/?' do
    if params[:payload].nil?
      add_i_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      add_i_error_json_string = JSON.generate(add_i_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           add_i_error_json_string
    end

    begin
      payload = JSON.parse(params[:payload])
    rescue JSON::ParserError
      add_i_error_json_hash = { message: 'I am a teapot', error: 418 }
      add_i_error_json_string = JSON.generate(add_i_error_json_hash)

      halt 418, { 'Content-Type' => 'application/json' },
           add_i_error_json_string
    end

    email = payload['email']
    password = payload['password']
    object_id = payload['object_id']

    parameter_array = [email, password, object_id]
    if parameter_array.include?(nil)
      add_i_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      add_i_error_json_string = JSON.generate(add_i_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           add_i_error_json_string
    end

    profile = Profile.get(email)
    if profile.nil?
      add_i_error_json_hash = { message: 'Bad credentials', error: 401 }
      add_i_error_json_string = JSON.generate(add_i_error_json_hash)

      halt 401, { 'Content-Type' => 'application/json' },
           add_i_error_json_string
    end

    password_hash = BCrypt::Password.new(profile.password_hash)
    if password_hash == password
      # Save new installation to the installation database

      installation = Installation.first_or_create({ object_id: object_id },
                                                  created_at: Time.now)
      installation.email = email

      installation.save

      if installation.saved?
        status 200
        add_i_success_json_hash = { email: email, object_id: object_id }
        add_i_success_json_string = JSON.generate(add_i_success_json_hash)

        content_type 'application/json'
        add_i_success_json_string
      else
        add_i_error_json_hash = {
          message: 'The given information could not be saved', error: 500 }
        add_i_error_json_string = JSON.generate(add_i_error_json_hash)

        halt 500, { 'Content-Type' => 'application/json' },
             add_i_error_json_string
      end

    else
      add_i_error_json_hash = { message: 'Bad credentials', error: 401 }
      add_i_error_json_string = JSON.generate(add_i_error_json_hash)

      halt 401, { 'Content-Type' => 'application/json' },
           add_i_error_json_string
    end
  end
end
