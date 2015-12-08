# The main class for all the WalkMyDog routes
class KWApi < Sinatra::Base
  # Test POST method
  post '/walkmydog/test/post/?' do
    test_json_hash = { message: 'It works', error: 'nil' }
    test_json_string = JSON.generate(test_json_hash)

    content_type 'application/json'
    test_json_string
  end

  # The post method to check a users password
  post '/walkmydog/users/login/?' do
  end

  # This happens if a user applies as a dogwalker
  post '/walkmydog/users/apply/?' do
    payload = JSON.parse(params[:payload])

    firstname = payload['firstname']
    lastname = payload['lastname']
    email = payload['email']
    password = payload['password']
    cell_phone_number = payload['cell_phone_number']
    street_address = payload['street_address']
    apartment_number = payload['apartment_number']
    city = payload['city']
    zip_code = payload['zip_code']
    is_walker = true

    walker_information = payload['walker_information']
    if walker_information.nil?
      status 422
      apply_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      apply_error_json_string = JSON.generate(apply_error_json_hash)

      content_type 'application/json'
      apply_error_json_string
    else
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
    end

    parameter_array = [firstname, lastname, email, password, cell_phone_number,
                       street_address, city, zip_code, walker_information,
                       position, experience_time, experience_text, type_of_pet,
                       walker_description, availability, education_level,
                       days_available, transportation, share_application]

    if parameter_array.include?(nil)
      status 422
      apply_error_json_hash = {
        message: 'The JSON payload is missing some elements which must be set',
        error: 422 }
      apply_error_json_string = JSON.generate(apply_error_json_hash)

      content_type 'application/json'
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
        profile.zip_code = zip_code
        profile.is_walker = is_walker
        profile.created_at = Time.now

        profile.save

        if profile.saved?
          email_file = open(File.expand_path('../json/email.json',
                                             File.dirname(__FILE__)))
          email_json = email_file.read
          email_parsed = JSON.parse(email_json)

          message = <<-MESSAGE_END
          From: developer <#{email_parsed['from']}>
          To: A Test User <#{email_parsed['to']}>
          MIME-Version: 1.0
          Content-type: text/html
          Subject: API email test

          This email was sent from api.kwstudios.org for the API tests

          Firstname: #{firstname}
          Lastname: #{lastname}
          Email: #{email}
          Cellphone number: #{cell_phone_number}
          Street address: #{street_address}
          Apartment number: #{apartment_number}
          City: #{city}
          Zip code: #{zip_code}

          Position: #{position}
          Experience time: #{experience_time}
          Experience text: #{experience_text}
          Type of own pets: #{type_of_pet}
          Description: #{walker_description}
          Availability: #{availability}
          Education level: #{education_level}
          Link to Profile: #{link_to_profile}
          Days available: #{days_available}
          Transportation: #{transportation}
          Share application: #{share_application}

MESSAGE_END

          sendgrid = SendGrid::Client.new do |c|
            c.api_key = email_parsed['api']
          end

          email = SendGrid::Mail.new do |m|
            m.to      = email_parsed['to']
            m.from    = email_parsed['from']
            m.subject = 'API email test'
            m.html    = message
          end

          sendgrid.send(email)

          # Net::SMTP.start(email_parsed['smtp'], email_parsed['port'],
          #                 'api.kwstudios.org', email_parsed['login'],
          #                 email_parsed['password'], :plain) do |smtp|
          #  smtp.send_message message, email_parsed['from'], email_parsed['to']
          # end

          status 200
          apply_success_json_hash = { firstname: firstname, lastname: lastname,
                                      email: email,
                                      cell_phone_number: cell_phone_number,
                                      street_address: street_address,
                                      apartment_number: apartment_number,
                                      city: city, zip_code: zip_code, pets: [] }
          apply_success_json_string = JSON.generate(apply_success_json_hash)

          content_type 'application/json'
          apply_success_json_string
        else
          status 500
          apply_error_json_hash = {
            message: 'The given information could not be saved', error: 500 }
          apply_error_json_string = JSON.generate(apply_error_json_hash)

          content_type 'application/json'
          apply_error_json_string
        end
      else
        status 409
        apply_error_json_hash = { message: 'This Email address already exists',
                                  error: 409 }
        apply_error_json_string = JSON.generate(apply_error_json_hash)

        content_type 'application/json'
        apply_error_json_string
      end
    end
  end

  # Test GET
  get '/walkmydog/test/get/?' do
    thisisnil = 4
    thisisnotnil = 5
    thisisalsonotnil = 6

    if [thisisnil, thisisnotnil, thisisalsonotnil].include?(nil)
      jsonout = { message: 'The array contains nil.' }
      jsonstring = JSON.generate(jsonout)

      content_type 'application/json'
      jsonstring
    else
      jsonout = { message: 'The array does not contain nil.' }
      jsonstring = JSON.generate(jsonout)

      content_type 'application/json'
      jsonstring
    end
  end
end
