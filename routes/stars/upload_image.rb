# The main class for uploading images
class KWApi < Sinatra::Base
  post '/stars/v1/fb/upload/png/?' do
    id = params[:id]
    token = params[:token]

    verify_fb_login(id, token)
    check_fb_registration(id)

    profile = Fbstarsprofile.get(id)

    image = params['image']

    halt 422, { 'Content-Type' => 'application/json' },
         missing_elements_json if image.nil?

    # image_type = image[:type]
    image_head = image[:head]
    tempfile = image[:tempfile]

    halt 415, { 'Content-Type' => 'application/json' },
         unsupported_media_type_json if image_head.nil?

    original_type = image_head['Content-Type']
    halt 415, { 'Content-Type' => 'application/json' },
         unsupported_media_type_json if original_type.nil?

    halt 415, { 'Content-Type' => 'application/json' },
         unsupported_media_type_json if tempfile.nil?

    puts original_type

    image_type = nil
    image_extension = nil
    if original_type.eql? 'image/png'
      image_type = 'image/png'
      image_extension = 'png'
    elsif original_type.eql?('image/jpg') || original_type.eql?('image/jpeg')
      image_type = 'image/jpg'
      image_extension = 'jpg'
    end

    halt 415, { 'Content-Type' => 'application/json' },
         unsupported_media_type_json if image_type.nil? ||
                                        image_extension.nil?

    # Handle GCS upload
    random_name = UUIDTools::UUID.random_create.to_s

    connection = Fog::Storage.new(
      provider: 'Google',
      google_storage_access_key_id: ENV['GCS_ACCESS_KEY'],
      google_storage_secret_access_key: ENV['GCS_SECRET']
    )

    gcs_bucket = ENV['GCS_BUCKET_STARS']
    directory = connection.directories.get("#{gcs_bucket}")

    mime_type = image_type

    file = directory.files.create(
      key: "images/#{image_extension}/#{random_name}.#{image_extension}",
      body: tempfile.read,
      content_type: mime_type,
      public: true
    )
    file.save

    # Save database entry
    gcs_image = profile.starsgcsimages.new
    gcs_image.gcs_key = file.key
    gcs_image.gcs_bucket = gcs_bucket
    gcs_image.content_type = mime_type

    profile.save

    unless profile.saved?
      image_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      image_error_json_string = JSON.generate(image_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           image_error_json_string
    end

    status 200

    image_success_json_string = get_stars_gcs_image_json_string(
      gcs_image)

    content_type 'application/json'
    image_success_json_string
  end
end
