# The Walkmydog app installation representing class
class Installation
  include DataMapper::Resource
  # property :id,                Serial
  property :object_id,         String, required: true, length: 255, key: true
  property :email,             String, required: true, length: 255
  property :created_at,        DateTime, required: true
end
