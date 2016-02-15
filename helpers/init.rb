# encoding: utf-8
require_relative 'partials'
KWApi.helpers LoginHelpers
KWApi.helpers ErrorCreators

require_relative 'geocoding'
KWApi.helpers GeocodingHelpers

require_relative 'dog_helpers'
KWApi.helpers DogHelpers
