# The main class for the WalkMyDog login route
class KWApi < Sinatra::Base
  post '/walkmydog/users/login/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])
    status 200
    login_success_json_hash = { firstname: profile.firstname,
                                lastname: profile.lastname,
                                email: profile.email,
                                cell_phone_number: profile.cell_phone_number,
                                street_address: profile.street_address,
                                apartment_number: profile.apartment_number,
                                city: profile.city, state: profile.state,
                                country: profile.country,
                                zip_code: profile.zip_code, pets: [] }
    login_success_json_string = JSON.generate(login_success_json_hash)

    content_type 'application/json'
    login_success_json_string
  end
end
