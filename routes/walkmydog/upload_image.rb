# The main class for uploading images
class KWApi < Sinatra::Base
  post '/walkmydog/users/image/upload/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    image = params['image']

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if image.nil?

    halt 415, { 'Content-Type' => 'application/json' },
         unsupported_media_type_json unless image[:type].eql? 'image/png'

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
      key: "users/images/#{random_name}.png",
      body: image[:tempfile].read,
      content_type: mime_type,
      public: true
    )
    file.save

    # Save database entry
    gcs_image = Gcsimage.new
    gcs_image.gcs_key = file.key
    gcs_image.gcs_bucket = gcs_bucket
    gcs_image.content_type = mime_type
    gcs_image.type = 'profile'

    profile.gcsimage = gcs_image
    profile.save

    unless profile.saved?
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

  post '/walkmydog/users/pets/:id/image/upload/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    image = params['image']

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if image.nil?

    halt 415, { 'Content-Type' => 'application/json' },
         unsupported_media_type_json unless image[:type].eql? 'image/png'

    pet = profile.dogprofiles.get(params['id'])
    halt 401, { 'Content-Type' => 'application/json' },
         bad_credentials_json if pet.nil?

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
      key: "users/pets/images/#{random_name}.png",
      body: image[:tempfile].read,
      content_type: mime_type,
      public: true
    )
    file.save

    # Save database entry
    gcs_image = Gcsimage.new
    gcs_image.gcs_key = file.key
    gcs_image.gcs_bucket = gcs_bucket
    gcs_image.content_type = mime_type
    gcs_image.type = 'petprofile'

    pet.gcsimage = gcs_image
    pet.save

    unless pet.saved?
      image_error_json_hash = {
        message: 'The given information could not be saved', error: 500
      }
      image_error_json_string = JSON.generate(image_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           image_error_json_string
    end

    status 200

    image_success_json_string = get_gcs_image_json_string(pet.gcsimage)

    content_type 'application/json'
    image_success_json_string
  end
end
