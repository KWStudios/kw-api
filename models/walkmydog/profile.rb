# The Walkmydog users representing database class
class Profile
  include DataMapper::Resource
  property :id,                Serial
  property :firstname,         Text, required: true
  property :lastname,          Text, required: true
  property :email,             Text, required: true, key: true
  property :password_hash,     Text, required: true
  property :cell_phone_number, Text, required: true
  property :street_address,    Text, required: true
  property :apartment_number,  Integer, required: false
  property :city,              Text, required: true
  property :zip_code,          String, required: true
  property :is_walker,         Boolean, default: false
  property :is_activated,      Boolean, default: false
  property :created_at,        DateTime, required: true
end
