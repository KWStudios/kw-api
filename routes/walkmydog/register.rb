# The main class for the WalkMyDog register route
# rubocop:disable ClassLength
class KWApi < Sinatra::Base
  # This happens if a user registers as a customer
  post '/walkmydog/users/register/?' do
    request.body.rewind
    payload_body = request.body.read
    if params[:payload].nil? && payload_body.nil?
      register_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      register_error_json_string = JSON.generate(register_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           register_error_json_string
    end

    raw_payload = [payload_body, params[:payload]].find { |i| !i.nil? }
    begin
      payload = JSON.parse(raw_payload)
    rescue JSON::ParserError
      login_error_json_hash = { message: 'I am a teapot', error: 418 }
      login_error_json_string = JSON.generate(login_error_json_hash)

      halt 418, { 'Content-Type' => 'application/json' },
           login_error_json_string
    end

    firstname = payload['firstname']
    lastname = payload['lastname']
    email = payload['email']
    password = payload['password']
    cell_phone_number = payload['cell_phone_number']
    street_address = payload['street_address']
    apartment_number = payload['apartment_number']
    city = payload['city']
    state = payload['state']
    country = payload['country']
    zip_code = payload['zip_code']
    is_walker = false

    parameter_array = [firstname, lastname, email, password, cell_phone_number,
                       street_address, city, state, country, zip_code]

    if parameter_array.include?(nil)
      register_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      register_error_json_string = JSON.generate(register_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           register_error_json_string
    else
      if Profile.count(email: email) == 0
        profile = Profile.new

        profile.firstname = firstname
        profile.lastname = lastname
        profile.email = email

        # ******* Password encryption *******
        # The password is being bcrypted with a "random" salt
        password_hash = BCrypt::Password.create(password)
        profile.password_hash = password_hash
        # ******* Password encryption end *******

        profile.cell_phone_number = cell_phone_number
        profile.street_address = street_address
        profile.apartment_number = apartment_number unless apartment_number.nil?
        profile.city = city
        profile.state = state
        profile.country = country
        profile.zip_code = zip_code
        profile.is_walker = is_walker
        profile.created_at = Time.now

        profile.save

        if profile.saved?
          email_file = open(File.expand_path('../../json/email.json',
                                             File.dirname(__FILE__)))
          email_json = email_file.read
          email_parsed = JSON.parse(email_json)

          sendgrid = SendGrid::Client.new do |c|
            c.api_key = email_parsed['api']
          end

          email = SendGrid::Mail.new do |m|
            m.to      = email
            m.from    = email_parsed['from']
            m.subject = 'API register test'
            m.html    = haml :"walkmydog/email_register"
          end

          sendgrid.send(email)

          # Start Geocoding in a background Process
          bg_geocoding = Process.fork do
            geocode_address(profile)
          end
          Process.detach bg_geocoding

          status 200

          register_success_json_string = get_profile_json_string(profile)

          content_type 'application/json'
          register_success_json_string
        else
          register_error_json_hash = {
            message: 'The given information could not be saved', error: 500 }
          register_error_json_string = JSON.generate(register_error_json_hash)

          halt 500, { 'Content-Type' => 'application/json' },
               register_error_json_string
        end
      else
        register_error_json_hash = {
          message: 'This Email address already exists', error: 409 }
        register_error_json_string = JSON.generate(register_error_json_hash)

        halt 409, { 'Content-Type' => 'application/json' },
             register_error_json_string
      end
    end
  end
end
