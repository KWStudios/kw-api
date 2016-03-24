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

    directory = connection.directories.get("#{ENV['GCS_SECRET']}")

    file = directory.files.create(
      key: "users/images/#{random_name}.png",
      body: image[:tempfile].read,
      public: true
    )

    # Save database entry
    gcs_image = Gcsimage.new
    gcs_image.gcs_key = file.key
    gcs_image.content_type = file.content_type
    gcs_image.type = 'profile'

    profile.gcsimage = gcs_image
    profile.save

    unless profile.saved?
      image_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      image_error_json_string = JSON.generate(image_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           image_error_json_string
    end

    status 200

    image_success_json_string = get_gcs_image_json_string(gcs_image)

    content_type 'application/json'
    image_success_json_string
  end
end
