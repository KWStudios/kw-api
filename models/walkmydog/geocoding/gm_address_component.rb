# The Google Maps AddressComponents representing class
class GMAddressComponent
  include DataMapper::Resource
  property :id,                Serial
  property :email,             String, required: true, length: 255
  property :long_name,         String, required: true, length: 255
  property :short_name,        String, required: true, length: 255
  property :created_at,        DateTime, required: true

  has n, :gmtypes

  belongs_to :gmresult
end
