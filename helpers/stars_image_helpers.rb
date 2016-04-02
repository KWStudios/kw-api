# encoding: utf-8

# All helpers for the stars images
module StarsImageHelpers
  def get_stars_gcs_image_json_string(stars_image)
    image_json_hash = get_stars_gcs_image_json_hash(stars_image)
    image_json_string = JSON.generate(image_json_hash)
    image_json_string
  end

  # rubocop:disable MethodLength
  def get_stars_gcs_image_json_hash(stars_image)
    if !stars_image.nil?
      gcs_url = 'https://storage.googleapis.com/'
      image_json_hash = { id: stars_image.id,
                          gcs_key: stars_image.gcs_key,
                          gcs_bucket: stars_image.gcs_bucket,
                          url: "#{gcs_url}#{stars_image.gcs_bucket}/"\
                            "#{stars_image.gcs_key}",
                          content_type: stars_image.content_type,
                          category: stars_image.category,
                          created_at: stars_image.created_at,
                          updated_at: stars_image.updated_at }
      return image_json_hash
    else
      image_json_hash = {}
      return image_json_hash
    end
  end
end
