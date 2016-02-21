# The route for getting dog profiles for a user profile
class KWApi < Sinatra::Base
  post '/walkmydog/users/pets/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    dog_profiles = get_dog_profiles_for_profile(profile)
    if dog_profiles.nil?
      content_type 'application/json'
      '[]'
    end

    dog_profiles_json_hash = []
    dog_profiles.each do |dog_profile|
      dog_profiles_json_hash << get_dog_profile_json_hash(dog_profile)
    end

    status 200
    dog_profiles_json_string = JSON.generate(dog_profiles_json_hash)

    content_type 'application/json'
    dog_profiles_json_string
  end
end
