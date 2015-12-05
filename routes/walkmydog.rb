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
    street_adress = payload['street_adress']
    apartment_number = payload['apartment_number']
    city = payload['city']
    zip_code = payload['zip_code']
  end

  # Test GET
  get '/walkmydog/test/get/?' do
    thisisnil = nil
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
