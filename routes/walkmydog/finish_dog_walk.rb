# The main class for uploading images
class KWApi < Sinatra::Base
  post %r{\A\/walkmydog\/users\/pets\/jobs\/([0-9][0-9]*)\/image\/(pee|poo|other)\/upload\/?\z} do
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

    image_success_json_string = get_gcs_image_json_string(profile.gcsimage)

    content_type 'application/json'
    image_success_json_string
  end
end
