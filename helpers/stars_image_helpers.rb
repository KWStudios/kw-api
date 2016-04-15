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

  # rubocop:disable CyclomaticComplexity
  def voted_for_image?(image, profile)
    return false if image.nil? || profile.nil?
    image_vote = image.starsimagevote
    profile_vote = profile.starsvote
    return false if image_vote.nil? || profile_vote.nil?
    upvotes = profile_vote.starsupvotes
    downvotes = profile_vote.starsdownvotes
    greatvotes = profile_vote.starsgreatvotes
    votes = [upvotes, downvotes, greatvotes]
    return false if votes.include?(nil)

    votes.each do |vote|
      return true unless vote.get(image_vote.id).nil?
    end

    false
  end
end
