# The main class for voting images
class KWApi < Sinatra::Base
  post %r{\A\/stars\/v1\/images\/([0-9][0-9]*)\/vote\/(up|down|great)\/?\z} do
    puts 'Route is running'
    id = params[:id]
    token = params[:token]

    verify_fb_login(id, token)
    check_fb_registration(id)

    profile = Fbstarsprofile.get(id)

    image = Starsgcsimage.get(params['captures'].first)

    halt 404 if image.nil?

    puts 'The following should be up down or great'
    puts params['captures'].second
    if params['captures'].second == 'up'
      vote = profile.starsvote.starsupvotes.new
      vote.starsimagevote = image
    elsif params['captures'].second == 'down'
      vote = profile.starsvote.starsdownvotes.new
      vote.starsimagevote = image
    elsif params['captures'].second == 'great'
      vote = profile.starsvote.starsgreatvotes.new
      vote.starsimagevote = image
    else
      halt 404
    end

    profile.save
    unless profile.saved?
      vote_error_json_hash = {
        message: 'The given information could not be saved', error: 500 }
      vote_error_json_string = JSON.generate(vote_error_json_hash)

      halt 500, { 'Content-Type' => 'application/json' },
           vote_error_json_string
    end

    status 200

    vote_success_json_string = get_stars_gcs_image_json_string(image)

    content_type 'application/json'
    vote_success_json_string
  end
end
