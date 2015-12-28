# encoding: utf-8

# All helpers for the WalkMyDog routes
module LoginHelpers
  def verify_login(payload)
    check_payload(payload)
    check_json(payload)
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
end
