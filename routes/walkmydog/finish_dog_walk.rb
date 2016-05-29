# The main class for uploading images
class KWApi < Sinatra::Base
  post %r{\A\/walkmydog\/users\/pets\/jobs\/([0-9][0-9]*)\/images\/(pee|poo|other)\/upload\/?\z} do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    image = params['image']
    job_id = params['captures'][0]

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if image.nil? || job_id.nil?

    halt 415, { 'Content-Type' => 'application/json' },
         unsupported_media_type_json unless image[:type].eql?('image/jpg') ||
                                            image[:type].eql?('image/jpeg')

    job = profile.dogwalks.get(job_id)

    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if job.nil? || job.was_finished

    # Handle GCS upload
    random_name = UUIDTools::UUID.random_create.to_s

    connection = Fog::Storage.new(
      provider: 'Google',
      google_storage_access_key_id: ENV['GCS_ACCESS_KEY'],
      google_storage_secret_access_key: ENV['GCS_SECRET']
    )

    gcs_bucket = ENV['GCS_BUCKET']
    directory = connection.directories.get("#{gcs_bucket}")

    mime_type = image[:type]

    file = directory.files.create(
      key: "users/jobs/#{job.id}/images/#{random_name}.jpg",
      body: image[:tempfile].read,
      content_type: mime_type,
      public: true
    )
    file.save

    # Save database entry
    gcs_image = job.gcsimages.new
    gcs_image.gcs_key = file.key
    gcs_image.gcs_bucket = gcs_bucket
    gcs_image.content_type = mime_type
    gcs_image.type = params['captures'][1]

    job.save

    unless job.saved?
      image_error_json_hash = {
        message: 'The given information could not be saved', error: 500
      }
      image_error_json_string = JSON.generate(image_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           image_error_json_string
    end

    status 200

    image_success_json_string = get_gcs_image_json_string(gcs_image)

    content_type 'application/json'
    image_success_json_string
  end

  post '/walkmydog/users/pets/jobs/:id/locations/upload/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    walk_information = params[:information]
    check_payload(walk_information)
    check_json(walk_information)

    walk_payload = JSON.parse(walk_information)
    locations = walk_payload['locations']

    job_id = params['id']

    walk_parameter_array = [locations, job_id]

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if walk_parameter_array.include?(nil) ||
                                  !locations.respond_to?('each')

    job = profile.dogwalks.get(job_id)
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if job.nil? || job.was_finished

    locations_json_hash = []
    locations.each do |loc|
      next if loc['latitude'].nil? || loc['longitude'].nil?
      location = job.jobLocations.new
      location.latitude = loc['latitude']
      location.longitude = loc['longitude']

      locations_json_hash << get_job_location_json_hash(location)
    end

    job.save

    unless job.saved?
      walk_error_json_hash = {
        message: 'The given information could not be saved', error: 500
      }
      walk_error_json_string = JSON.generate(walk_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           walk_error_json_string
    end

    status 200

    locations_json_string = JSON.generate(locations: locations_json_hash)

    content_type 'application/json'
    locations_json_string
  end
end
