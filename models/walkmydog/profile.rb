# The Walkmydog users representing database class
class Profile
  include DataMapper::Resource
  # property :id,                Serial
  property :firstname,         Text, required: true
  property :lastname,          Text, required: true
  property :email,             String, required: true, length: 255, key: true
  property :password_hash,     Text, required: true
  property :cell_phone_number, Text, required: true
  property :street_address,    Text, required: true
  property :apartment_number,  Integer, required: false
  property :city,              Text, required: true
  property :state,             Text, required: true
  property :country,           Text, required: true
  property :zip_code,          String, required: true
  property :is_walker,         Boolean, default: false
  property :is_activated,      Boolean, default: false
  property :latitude,          Float, required: false
  property :longitude,         Float, required: false
  property :created_at,        DateTime, required: true
end
