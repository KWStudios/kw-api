# The Google Maps Types representing class
class Gmtype
  include DataMapper::Resource
  property :id,                Serial
  property :email,             String, required: true, length: 255
  property :type,              String, required: true, length: 255
  property :created_at,        DateTime, required: true

  belongs_to :gmaddresscomponent, required: false
  belongs_to :gmresult, required: false
end
