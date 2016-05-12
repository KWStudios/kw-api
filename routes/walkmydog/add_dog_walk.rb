# The route for adding dog profiles
class KWApi < Sinatra::Base
  post '/walkmydog/users/pets/jobs/add/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    walk_information = params[:information]
    check_payload(walk_information)
    check_json(walk_information)

    walk_payload = JSON.parse(walk_information)
    scheduled_time = walk_payload['scheduled_time']
    timeframe_lower = walk_payload['timeframe_lower']
    timeframe_upper = walk_payload['timeframe_upper']
    type_of_job = walk_payload['type_of_job']
    dog_profile_id = walk_payload['dog_profile']['id']

    walk_parameter_array = [scheduled_time, type_of_job, dog_profile_id,
                            timeframe_lower, timeframe_upper]

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if walk_parameter_array.include?(nil)

    dog_profile = profile.dogprofiles.get(dog_profile_id)
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if dog_profile.nil?

    notes = walk_payload['notes']

    dog_walk = dog_profile.dogwalks.new
    dog_walk.scheduled_time = scheduled_time
    dog_walk.timeframe_lower = timeframe_lower
    dog_walk.timeframe_upper = timeframe_upper
    dog_walk.type_of_job = type_of_job
    dog_walk.notes = notes

    is_weekly = walk_payload['is_weekly']
    if !is_weekly.nil? && is_weekly
      dog_walk.is_weekly = true
    else
      dog_walk.is_weekly = false
    end

    dog_profile.save

    unless dog_profile.saved?
      walk_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      walk_error_json_string = JSON.generate(walk_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           walk_error_json_string
    end

    status 200
    walk_json_string = get_dog_walk_json_string(dog_walk)

    content_type 'application/json'
    walk_json_string
  end
end
