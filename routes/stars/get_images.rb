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

  post '/stars/v1/images/next/?' do
    id = params[:id]
    token = params[:token]

    check_fb_registration(id)
    verify_fb_login(id, token)

    profile = Fbstarsprofile.get(id)

    images = Starsgcsimage.all(limit: 10) -
             Starsgcsimage.all(Starsgcsimage.starsimagevote.starsupvotes
                               .starsvote.fbstarsprofile.id => id)

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
