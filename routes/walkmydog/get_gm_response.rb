# The main class for the WalkMyDog geocoding route
class KWApi < Sinatra::Base
  post '/walkmydog/users/geocoding/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    gm_results = []

    profile.gmresponse.gmresults.each do |result|
      gm_address_components = []

      result.gmaddresscomponents.each do |component|
        gm_types = []
        component.gmtypes.each do |type|
          gm_types << type.type
        end

        gm_component = { long_name: component.long_name,
                         short_name: component.short_name, types: gm_types }
        gm_address_components << gm_component
      end

      gm_location = { lat: result.gmgeometry.location_lat,
                      lng: result.gmgeometry.location_lng }

      gm_ne = { lat: result.gmgeometry.viewport_ne_lat,
                lng: result.gmgeometry.viewport_ne_lng }
      gm_sw = { lat: result.gmgeometry.viewport_sw_lat,
                lng: result.gmgeometry.viewport_sw_lng }

      gm_viewport = { northeast: gm_ne, southwest: gm_sw }

      gm_geometry = { location: gm_location,
                      location_type: result.gmgeometry.location_type,
                      viewport: gm_viewport }

      gm_types = []
      result.gmtypes.each do |type|
        gm_types << type.type
      end

      gm_result = { address_components: gm_address_components,
                    formatted_address: result.formatted_address,
                    geometry: gm_geometry, place_id: result.place_id,
                    types: gm_types }
      gm_results << gm_result
    end

    gm_response = { results: gm_results, status: profile.gmresponse.status }

    gm_json_string = JSON.generate(gm_response)

    status 200
    content_type 'application/json'
    gm_json_string
  end
end
