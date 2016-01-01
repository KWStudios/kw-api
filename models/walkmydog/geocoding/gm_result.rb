# The Google Maps Results representing class
class GMResult
  include DataMapper::Resource
  property :id,                Serial
  property :email,             String, required: true, length: 255
  property :formatted_address, Text, required: true
  property :place_id,          Text, required: true
  property :created_at,        DateTime, required: true

  has n, :gmaddresscomponents
  has n, :gmtypes
  has 1, :gmgeometry

  belongs_to :gmresponse
end
