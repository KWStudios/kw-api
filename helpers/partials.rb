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
end
