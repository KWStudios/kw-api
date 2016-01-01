# The Google Maps Geocoding Response representing class
class Gmresponse
  include DataMapper::Resource
  # property :id,                Serial
  property :email,             String, required: true, length: 255, key: true
  property :status,            String, required: true, length: 255
  property :created_at,        DateTime, required: true

  has n, :gmresults

  belongs_to :profile
end
