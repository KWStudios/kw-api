# The main class for uploading images
class KWApi < Sinatra::Base
  post '/walkmydog/users/pets/jobs/:id/edit/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    walk_information = params[:information]
    check_payload(walk_information)
    check_json(walk_information)

    walk_payload = JSON.parse(walk_information)
    notes = walk_payload['notes']

    job_id = params['id']

    walk_parameter_array = [notes, job_id]

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if walk_parameter_array.include?(nil)

    job = Dogwalk.get(job_id)
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if job.nil? || job.was_finished

    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json unless profile.is_admin ||
                                     job.dogprofile.profile.email ==
                                     profile.email

    job.notes = notes

    job.save

    unless job.saved?
      walk_error_json_hash = {
        message: 'The given information could not be saved', error: 500
      }
      walk_error_json_string = JSON.generate(walk_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           walk_error_json_string
    end

    # Start messaging in a background Process
    Thread.new do
      send_notification_to_profile('Walk',
                                   "The notes for #{job.dogprofile.pet_name}"\
                                   'changed!',
                                   assignee_profile)
    end

    status 200

    dog_walk_json_string = get_dog_walk_json_string(job)

    content_type 'application/json'
    dog_walk_json_string
  end
end
