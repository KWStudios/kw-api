# encoding: utf-8

# All helpers for the stars images
module StarsImageHelpers
  def get_stars_gcs_image_json_string(stars_image)
    image_json_hash = get_stars_gcs_image_json_hash(stars_image)
    image_json_string = JSON.generate(image_json_hash)
    image_json_string
  end

  # rubocop:disable MethodLength, AbcSize
  def get_stars_gcs_image_json_hash(stars_image)
    if !stars_image.nil?
      uploader_hash = {}
      unless stars_image.fbstarsprofile.nil?
        uploader_hash = get_fb_stars_profile_json_hash(
          stars_image.fbstarsprofile)
      end

      upvotes = 0
      downvotes = 0
      greatvotes = 0

      votes = stars_image.starsimagevote
      unless votes.nil?
        upvotes = votes.starsupvotes.all.count
        downvotes = votes.starsdownvotes.all.count
        greatvotes = votes.starsgreatvotes.all.count
      end

      gcs_url = 'https://storage.googleapis.com/'
      image_json_hash = { id: stars_image.id,
                          gcs_key: stars_image.gcs_key,
                          gcs_bucket: stars_image.gcs_bucket,
                          url: "#{gcs_url}#{stars_image.gcs_bucket}/"\
                            "#{stars_image.gcs_key}",
                          content_type: stars_image.content_type,
                          category: stars_image.category,
                          upvotes: upvotes,
                          downvotes: downvotes,
                          greatvotes: greatvotes,
                          uploader: uploader_hash,
                          created_at: stars_image.created_at,
                          updated_at: stars_image.updated_at }
      return image_json_hash
    else
      image_json_hash = {}
      return image_json_hash
    end
  end

  def voted_for_image?(image, profile)
    return false if image.nil? || profile.nil?

    ups = Starsupvote.all(Starsupvote.starsvote.id => profile.starsvote.id,
                          Starsupvote.starsimagevote.starsgcsimage.id =>
                            image.id)
    downs =
      Starsdownvote.all(Starsdownvote.starsvote.id => profile.starsvote.id,
                        Starsdownvote.starsimagevote.starsgcsimage.id =>
                          image.id)
    greats =
      Starsgreatvote.all(Starsgreatvote.starsvote.id => profile.starsvote.id,
                         Starsgreatvote.starsimagevote.starsgcsimage.id =>
                           image.id)

    return true unless ups.empty? && downs.empty? && greats.empty?

    false
  end
end
