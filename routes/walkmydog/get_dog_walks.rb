# The route for dog walks
class KWApi < Sinatra::Base
  post '/walkmydog/users/pets/jobs/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    dog_profiles = get_dog_profiles_for_profile(profile)
    if dog_profiles.nil?
      content_type 'application/json'
      '[]'
    end

    dog_walks_json_hash = []
    dog_profiles.each do |dog_profile|
      dog_walks = get_dog_walks_for_dog_profile(dog_profile)
      dog_walks.each do |dog_walk|
        dog_walks_json_hash << get_dog_walk_json_hash(dog_walk)
      end
    end

    status 200
    dog_walks_json_string = JSON.generate(dog_walks_json_hash)

    content_type 'application/json'
    dog_walks_json_string
  end

  post '/walkmydog/users/pets/:id/jobs/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    dog_profile_id = params['id']

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if dog_profile_id.nil?

    dog_profile = profile.dogprofiles.get(dog_profile_id)
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if dog_profile.nil?

    dog_walks_json_hash = []
    dog_walks = get_dog_walks_for_dog_profile(dog_profile)
    dog_walks.each do |dog_walk|
      dog_walks_json_hash << get_dog_walk_json_hash(dog_walk)
    end

    status 200
    dog_walks_json_string = JSON.generate(dog_walks_json_hash)

    content_type 'application/json'
    dog_walks_json_string
  end

  post '/walkmydog/users/jobs/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    unless profile.is_walker
      content_type 'application/json'
      '[]'
    end

    dog_walks = get_dog_walks_for_profile(profile)

    dog_walks_json_hash = []
    dog_walks.each do |dog_walk|
      dog_walks_json_hash << get_dog_walk_json_hash(dog_walk)
    end

    status 200
    dog_walks_json_string = JSON.generate(dog_walks_json_hash)

    content_type 'application/json'
    dog_walks_json_string
  end

  post '/walkmydog/users/jobs/queued/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json unless profile.is_admin

    dog_walks = Dogwalk.all(was_finished: false)

    dog_walks_json_hash = []
    dog_walks.each do |dog_walk|
      dog_walks_json_hash << get_dog_walk_json_hash(dog_walk)
    end

    status 200
    dog_walks_json_string = JSON.generate(dog_walks_json_hash)

    content_type 'application/json'
    dog_walks_json_string
  end

  post '/walkmydog/users/pets/jobs/:id/locations/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    job = Dogwalk.get(params['id'])
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if job.nil?

    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json unless profile.is_admin ||
                                     !profile.dogwalks.get(params['id']).nil? ||
                                     job.dogprofile.profile.email ==
                                     profile.email

    locations = []
    job.jobLocations.each do |loc|
      locations << get_job_location_json_hash(loc)
    end

    status 200
    locations_json_string = JSON.generate(locations)

    content_type 'application/json'
    locations_json_string
  end
end
