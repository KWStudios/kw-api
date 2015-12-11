# The main class for the WalkMyDog login route
class KWApi < Sinatra::Base
  post '/walkmydog/users/login/?' do
    if params[:payload].nil?
      login_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      login_error_json_string = JSON.generate(login_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           login_error_json_string
    end

    payload = nil
    begin
      payload = JSON.parse(params[:payload])
    rescue JSON::ParserError
      login_error_json_hash = { message: 'I’m a teapot', error: 418 }
      login_error_json_string = JSON.generate(login_error_json_hash)
    end

    halt 422, { 'Content-Type' => 'application/json' },
         login_error_json_string

    email = payload['email']
    password = payload['password']

    parameter_array = [email, password]
    if parameter_array.include?(nil)
      login_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      login_error_json_string = JSON.generate(login_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           login_error_json_string
    end

    profile = Profile.get(email)
    if profile.nil?
      login_error_json_hash = { message: 'Bad credentials', error: 401 }
      login_error_json_string = JSON.generate(login_error_json_hash)

      halt 401, { 'Content-Type' => 'application/json' },
           login_error_json_string
    end

    password_hash = BCrypt::Password.new(profile.password_hash)
    if password_hash == password
      status 200
      login_success_json_hash = { firstname: profile.firstname,
                                  lastname: profile.lastname,
                                  email: profile.email,
                                  cell_phone_number: profile.cell_phone_number,
                                  street_address: profile.street_address,
                                  apartment_number: profile.apartment_number,
                                  city: profile.city,
                                  zip_code: profile.zip_code, pets: [] }
      login_success_json_string = JSON.generate(login_success_json_hash)

      content_type 'application/json'
      login_success_json_string
    else
      login_error_json_hash = { message: 'Bad credentials', error: 401 }
      login_error_json_string = JSON.generate(login_error_json_hash)

      halt 401, { 'Content-Type' => 'application/json' },
           login_error_json_string
    end
  end
end
