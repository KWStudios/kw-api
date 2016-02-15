# The route for adding dog profiles
class KWApi < Sinatra::Base
  post '/walkmydog/users/pet/add/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    dog_information = params[:information]
    check_payload(dog_information)
    check_json(dog_information)

    dog_payload = JSON.parse(dog_information)
    pet_species = dog_payload['pet_species']
    pet_name = dog_payload['pet_name']

    dog_parameter_array = [pet_species, pet_name]

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if dog_parameter_array.include?(nil)

    alarm_system_info = dog_payload['alarm_system_info']
    pet_characteristics = dog_payload['pet_characteristics']

    dog_profile = profile.dogprofiles.new
    dog_profile.pet_species = pet_species
    dog_profile.pet_name = pet_name
    dog_profile.alarm_system_info = alarm_system_info
    dog_profile.pet_characteristics = pet_characteristics

    profile.save

    unless profile.saved?
      dog_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      dog_error_json_string = JSON.generate(dog_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           dog_error_json_string
    end

    status 200
    dog_json_string = get_dog_profile_json_string(dog_profile)

    content_type 'application/json'
    dog_json_string
  end
end
