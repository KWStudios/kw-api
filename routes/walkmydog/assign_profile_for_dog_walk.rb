# The route for adding dog profiles
class KWApi < Sinatra::Base
  post '/walkmydog/users/pets/jobs/:id/assign/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json unless profile.is_admin

    walk_information = params[:information]
    check_payload(walk_information)
    check_json(walk_information)

    walk_payload = JSON.parse(walk_information)
    walk_id = params[:id]
    assignee_email = walk_payload['assignee_email']

    walk_parameter_array = [walk_id, assignee_email]

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if walk_parameter_array.include?(nil)

    assignee_profile = Profile.get(assignee_email)
    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if assignee_profile.nil? ||
                                  !assignee_profile.is_walker

    dog_walk = Dogwalk.get(walk_id)
    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if dog_walk.nil?

    assignee_profile.dogwalks << dog_walk

    assignee_profile.save

    unless assignee_profile.saved?
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
