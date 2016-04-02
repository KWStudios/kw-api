# encoding: utf-8

# All helpers for the facebook login
module FBLoginHelpers
  def verify_fb_login(id, token)
    check_fb_auth(id, token)
  end

  def check_fb_auth(id, token)
    parameter_array = [id, token]
    return halt 422, { 'Content-Type' => 'application/json' },
                missing_elements_json if parameter_array.include?(nil)

    return halt 401, { 'Content-Type' => 'application/json' },
                bad_credentials_json unless valid_fb_login?(id, token)
  end

  def valid_fb_login?(id, token)
    response = get_fb_debug_token_response(token)
    if valid_json?(response)
      return valid_fb_debug_token_response?(id, JSON.parse(response))
    else
      return false
    end
  end

  def get_fb_debug_token_response(token)
    secret = "#{ENV['STARS_FB_APP_ID']}|#{ENV['STARS_FB_APP_SECRET']}"

    request = Typhoeus::Request.new(
      'https://graph.facebook.com/debug_token',
      method: :get,
      body: '',
      params: { input_token: token, access_token: secret }
    )
    request.run

    response = request.response.body
    response
  end

  def valid_fb_debug_token_response?(id, json)
    data = json['data']
    return false if data.nil?

    app_id = data['app_id']
    return false if app_id.nil?
    user_id = data['user_id']
    return false if user_id.nil?

    return true if user_id == id

    false
  end

  def get_fb_stars_profile_json_string(fbprofile)
    profile_json_hash = get_fb_stars_profile_json_hash(fbprofile)
    profile_json_string = JSON.generate(profile_json_hash)
    profile_json_string
  end

  # rubocop:disable MethodLength
  def get_fb_stars_profile_json_hash(fbprofile)
    profile_json_hash = { id: fbprofile.id,
                          name: fbprofile.name,
                          first_name: fbprofile.first_name,
                          last_name: fbprofile.last_name,
                          link: fbprofile.link,
                          gender: fbprofile.gender,
                          locale: fbprofile.locale,
                          timezone: fbprofile.timezone,
                          updated_time: fbprofile.updated_time,
                          verified: fbprofile.verified,
                          email: fbprofile.email }
    profile_json_hash
  end
end
