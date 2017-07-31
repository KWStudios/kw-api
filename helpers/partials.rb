# encoding: utf-8

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
    error_hash = { message: 'Unsupported Media Type', error: 415 }
    error_string = JSON.generate(error_hash)
    error_string
  end

  def missing_parameters_json
    error_hash = { message: 'Missing parameters', error: 422 }
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
