# The route for getting all installations for a profile
class KWApi < Sinatra::Base
  post '/walkmydog/users/installations/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    installations = get_installations_for_profile(profile)
    if installations.nil?
      content_type 'application/json'
      '[]'
    end

    installations_json_hash = []
    installations.each do |installation|
      installations_json_hash << get_installation_json_hash(installation)
    end

    status 200
    installations_json_string = JSON.generate(installations_json_hash)

    content_type 'application/json'
    installations_json_string
  end
end
