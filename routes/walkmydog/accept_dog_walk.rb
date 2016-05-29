# The route for dog walks
class KWApi < Sinatra::Base
  post '/walkmydog/users/pets/jobs/:id/accept/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    dog_walk_id = params['id']

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if dog_walk_id.nil?

    dog_walk = profile.dogwalks.get(dog_walk_id)
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if dog_walk.nil? || dog_walk.was_finished

    dog_walk.was_acknowledged = true
    dog_walk.save

    unless dog_walk.saved?
      dog_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      dog_error_json_string = JSON.generate(dog_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           dog_error_json_string
    end

    status 200
    dog_walk_json_string = get_dog_walk_json_string(dog_walk)

    content_type 'application/json'
    dog_walk_json_string
  end

  post '/walkmydog/users/pets/jobs/:id/decline/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    dog_walk_id = params['id']

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if dog_walk_id.nil?

    dog_walk = profile.dogwalks.get(dog_walk_id)
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if dog_walk.nil? || dog_walk.was_finished

    dog_walk.was_acknowledged = false
    dog_walk.save

    unless dog_walk.saved?
      dog_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      dog_error_json_string = JSON.generate(dog_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           dog_error_json_string
    end

    status 200
    dog_walk_json_string = get_dog_walk_json_string(dog_walk)

    content_type 'application/json'
    dog_walk_json_string
  end
end
