# The main class for getting the images
class KWApi < Sinatra::Base
  get '/stars/v1/images/all/?' do
    images = Starsgcsimage.all

    images_hash = []
    images.each do |image|
      images_hash << get_stars_gcs_image_json_hash(image)
    end

    status 200

    images_success_json_string = JSON.generate(images_hash)

    content_type 'application/json'
    images_success_json_string
  end
end
