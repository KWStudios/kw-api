# encoding: utf-8

# All helpers for the WalkMyDog routes
module LoginHelpers
  def verify_login(payload)
    check_payload(payload)
    check_json(payload)
    check_login_parameters(payload)
  end

  def check_payload(payload)
    return halt 422, { 'Content-Type' => 'application/json' },
                missing_elements_json if payload.nil?
  end

  def check_json(payload)
    JSON.parse(payload)
  rescue JSON::ParserError
    return halt 418, { 'Content-Type' => 'application/json' },
                teapot_json
  end

  def check_login_parameters(payload)
    json_payload = JSON.parse(payload)
    email = json_payload['email']
    password = json_payload['password']

    parameter_array = [email, password]
    return halt 422, { 'Content-Type' => 'application/json' },
                missing_elements_json if parameter_array.include?(nil)

    check_login_email(email)
    check_login_password(Profile.get(email), password)
  end

  def check_login_email(email)
    profile = Profile.get(email)
    return halt 401, { 'Content-Type' => 'application/json' },
                bad_credentials_json if profile.nil?
  end

  def check_login_password(profile, password)
    password_hash = BCrypt::Password.new(profile.password_hash)

    return halt 401, { 'Content-Type' => 'application/json' },
                bad_credentials_json unless password_hash == password
  end

  def get_profile_json_string(profile)
    profile_json_hash = get_profile_json_hash(profile)
    profile_json_string = JSON.generate(profile_json_hash)
    profile_json_string
  end

  # rubocop:disable MethodLength
  def get_profile_json_hash(profile)
    profile_json_hash = { firstname: profile.firstname,
                          lastname: profile.lastname,
                          email: profile.email,
                          cell_phone_number: profile.cell_phone_number,
                          street_address: profile.street_address,
                          apartment_number: profile.apartment_number,
                          city: profile.city, state: profile.state,
                          country: profile.country,
                          zip_code: profile.zip_code, pets: [],
                          is_walker: profile.is_walker,
                          is_admin: profile.is_admin,
                          braintree_id: profile.braintree_id,
                          profile_image:
                            get_gcs_image_json_hash(profile.gcsimage) }
    profile_json_hash
  end

  def get_gcs_image_json_string(gcs_image)
    image_json_hash = get_gcs_image_json_hash(gcs_image)
    image_json_string = JSON.generate(image_json_hash)
    image_json_string
  end

  def get_gcs_image_json_hash(gcs_image)
    if !gcs_image.nil?
      gcs_url = 'https://storage.googleapis.com/'
      image_json_hash = { id: gcs_image.id,
                          gcs_key: gcs_image.gcs_key,
                          gcs_bucket: gcs_image.gcs_bucket,
                          url: "#{gcs_url}#{gcs_image.gcs_bucket}/"\
                            "#{gcs_image.gcs_key}",
                          content_type: gcs_image.content_type,
                          type: gcs_image.type,
                          created_at: gcs_image.created_at,
                          updated_at: gcs_image.updated_at }
      return image_json_hash
    else
      image_json_hash = {}
      return image_json_hash
    end
  end
end

# The JSON errors are created with these helpers
module ErrorCreators
  def missing_elements_json
    error_hash = {
      message: 'The JSON payload is missing some elements which must be set',
      error: 422 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def teapot_json
    error_hash = { message: 'I am a teapot', error: 418 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def bad_credentials_json
    error_hash = { message: 'Bad credentials', error: 401 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def conflict_json
    error_hash = { message: 'Conflict', error: 409 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def already_voted_json
    error_hash = { message: 'Already Voted', error: 409 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def internal_server_error_json
    error_hash = { message: 'Internal Server Error', error: 500 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def unsupported_media_type_json
    error_hash = { message: 'Unsupported Media Type	', error: 415 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def valid_json?(payload)
    return false unless payload.is_a?(String)
    JSON.parse(payload).all?
  rescue JSON::ParserError
    return false
  end
end
