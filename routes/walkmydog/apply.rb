# The main class for the WalkMyDog apply route
# rubocop:disable ClassLength
class KWApi < Sinatra::Base
  # This happens if a user applies as a dogwalker
  post '/walkmydog/users/apply/?' do
    request.body.rewind
    payload_body = request.body.read
    if params[:payload].nil? && payload_body.nil?
      apply_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      apply_error_json_string = JSON.generate(apply_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           apply_error_json_string
    end

    raw_payload = [payload_body, params[:payload]].find { |i|
      !i.nil? && !i.strip.empty?
    }
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
    is_walker = true

    walker_information = payload['walker_information']
    if walker_information.nil?
      apply_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      apply_error_json_string = JSON.generate(apply_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           apply_error_json_string
    end

    position = walker_information['position']
    experience_time = walker_information['experience_time']
    experience_text = walker_information['experience_text']
    type_of_pet = walker_information['type_of_pet']
    walker_description = walker_information['walker_description']
    availability = walker_information['availability']
    education_level = walker_information['education_level']
    link_to_profile = walker_information['link_to_profile']
    days_available = walker_information['days_available']
    transportation = walker_information['transportation']
    share_application = walker_information['share_application']

    parameter_array = [firstname, lastname, email, password, cell_phone_number,
                       street_address, city, state, country, zip_code,
                       walker_information, position, experience_time,
                       experience_text, type_of_pet, walker_description,
                       availability, education_level, days_available,
                       transportation, share_application]

    if parameter_array.include?(nil)
      apply_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      apply_error_json_string = JSON.generate(apply_error_json_hash)

      halt 422, { 'Content-Type' => 'application/json' },
           apply_error_json_string
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

          @email_items = [
            ['Firstname', firstname],
            ['Lastname', lastname],
            ['Email', email],
            ['Cellphone number', cell_phone_number],
            ['Street address', street_address],
            ['Apartment number', apartment_number],
            ['City', city],
            ['State', state],
            ['Country', country],
            ['Zip code', zip_code],
            ['Position', position],
            ['Experience time', experience_time],
            ['Experience text', experience_text],
            ['Type of own pets', type_of_pet],
            ['Description', walker_description],
            ['Availability', availability],
            ['Education level', education_level],
            ['Link to Profile', link_to_profile],
            ['Days available', days_available],
            ['Transportation', transportation],
            ['Share application', share_application]
          ]
          sendgrid = SendGrid::Client.new do |c|
            c.api_key = email_parsed['api']
          end

          email = SendGrid::Mail.new do |m|
            m.to      = email_parsed['to']
            m.from    = email_parsed['from']
            m.subject = 'API email test'
            m.html    = haml :"walkmydog/email_apply"
          end

          sendgrid.send(email)

          # Start Geocoding in a background Process
          bg_geocoding = Process.fork do
            geocode_address(profile)
          end
          Process.detach bg_geocoding

          status 200

          apply_success_json_string = get_profile_json_string(profile)

          content_type 'application/json'
          apply_success_json_string
        else
          apply_error_json_hash = {
            message: 'The given information could not be saved', error: 500 }
          apply_error_json_string = JSON.generate(apply_error_json_hash)

          halt 500, { 'Content-Type' => 'application/json' },
               apply_error_json_string
        end
      else
        apply_error_json_hash = { message: 'This Email address already exists',
                                  error: 409 }
        apply_error_json_string = JSON.generate(apply_error_json_hash)

        halt 409, { 'Content-Type' => 'application/json' },
             apply_error_json_string
      end
    end
  end
end
