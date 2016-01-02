# encoding: utf-8

# Helpers for the Geocoding request
module GeocodingHelpers
  set :gm_server_key, ENV['GM_SERVER_KEY']

  def geocode_address(profile)
    response = get_geocode_response(profile)
    save_gm_response(profile, JSON.parse(response)) if valid_json?(response)
  end

  def get_geocode_response(profile)
    address = "#{profile.street_address}, #{profile.city}, #{profile.state}"

    request = Typhoeus::Request.new(
      'https://maps.googleapis.com/maps/api/geocode/json',
      method: :get,
      body: '',
      params: { address: address, key: settings.gm_server_key }
    )
    request.run

    response = request.response.body
    response
  end

  def save_gm_response(profile, json)
    gm_response = Gmresponse.new
    gm_response.email = profile.email
    gm_response.status = json['status']

    save_gm_results(gm_response, json, profile)

    gm_response.created_at = Time.now

    profile.gmresponse = gm_response
    profile.save
  end

  def save_gm_results(gmresponse, json, profile)
    json['results'].each do |result|
      gm_result = gmresponse.gmresults.new
      gm_result.email = profile.email
      gm_result.formatted_address = result['formatted_address']
      gm_result.place_id = result['place_id']

      save_gm_address_components(gm_result, result, profile)
      save_gm_types(gm_result, result, profile)

      gm_result.gmgeometry = get_gm_geometry(result, profile)

      gm_result.created_at = Time.now
    end
  end

  def save_gm_address_components(gm_result, json, profile)
    json['address_components'].each do |component|
      gm_component = gm_result.gmaddresscomponents.new
      gm_component.email = profile.email
      gm_component.long_name = component['long_name']
      gm_component.short_name = component['short_name']

      save_gm_types(gm_component, component, profile)

      gm_component.created_at = Time.now
    end
  end

  def save_gm_types(parent, json, profile)
    json['types'].each do |type|
      gm_type = parent.gmtypes.new
      gm_type.email = profile.email
      gm_type.type = type
      gm_type.created_at = Time.now
    end
  end

  # rubocop:disable AbcSize, MethodLength
  def get_gm_geometry(json, profile)
    gm_json = json['geometry']

    gm_geometry = Gmgeometry.new
    gm_geometry.email = profile.email

    gm_geometry.location_lat = gm_json['location']['lat']
    gm_geometry.location_lng = gm_json['location']['lng']

    gm_geometry.location_type = gm_json['location_type']

    gm_geometry.viewport_ne_lat = gm_json['viewport']['northeast']['lat']
    gm_geometry.viewport_ne_lng = gm_json['viewport']['northeast']['lng']

    gm_geometry.viewport_sw_lat = gm_json['viewport']['southwest']['lat']
    gm_geometry.viewport_sw_lng = gm_json['viewport']['southwest']['lng']

    gm_geometry.created_at = Time.now

    gm_geometry
  end
end
