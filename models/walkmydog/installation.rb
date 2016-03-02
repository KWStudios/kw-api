# The Walkmydog app installation representing class
class Installation
  include DataMapper::Resource
  # property :id,                Serial
  property :gcm_sender_id,     String, required: true, length: 255, key: true
  property :device_identifier, String, required: true, length: 255
  property :created_at,        DateTime
  property :updated_at,        DateTime

  belongs_to :profile
end
