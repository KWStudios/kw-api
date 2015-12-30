# The Google Maps Geocoding Response representing class
class GMResponse
  include DataMapper::Resource
  # property :id,                Serial
  property :email,             String, required: true, length: 255, key: true
  property :created_at,        DateTime, required: true
end
