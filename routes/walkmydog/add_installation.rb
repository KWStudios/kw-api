# The main class for the WalkMyDog add installation route
class KWApi < Sinatra::Base
  post '/walkmydog/users/installations/add/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    gcm_information = params[:information]
    check_payload(gcm_information)
    check_json(gcm_information)

    gcm_payload = JSON.parse(gcm_information)
    gcm_token = gcm_payload['gcm_token']
    device_identifier = gcm_payload['device_identifier']

    gcm_parameter_array = [gcm_token, device_identifier]

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if gcm_parameter_array.include?(nil)

    gcm_token = gcm_token.strip

    return halt 418, { 'Content-Type' => 'application/json' },
                teapot_json if gcm_token.match(/\s/)

    return halt 418, { 'Content-Type' => 'application/json' },
                teapot_json if gcm_token.length >= 255

    return halt 409, { 'Content-Type' => 'application/json' },
                conflict_json unless Installation.get(gcm_token).nil?

    installation = profile.installations.new
    installation.gcm_token = gcm_token
    installation.device_identifier = device_identifier

    profile.save

    unless profile.saved?
      gcm_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      gcm_error_json_string = JSON.generate(gcm_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           gcm_error_json_string
    end

    status 200
    gcm_json_string = get_installation_json_string(installation)

    content_type 'application/json'
    gcm_json_string
  end
end
