# The Google Maps Geometry representing class
class GMGeometry
  include DataMapper::Resource
  property :id,                Serial
  property :email,             String, required: true, length: 255
  property :location_lat,      Float, required: true
  property :location_lng,      Float, required: true

  property :location_type,     String, required: true, length: 255

  property :viewport_ne_lat,   Float, required: true
  property :viewport_ne_lng,   Float, required: true

  property :viewport_sw_lat,   Float, required: true
  property :viewport_sw_lng,   Float, required: true

  property :created_at,        DateTime, required: true

  belongs_to :gmresult
end
