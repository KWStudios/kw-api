# The Walkmydog users representing database class
class Profile
  include DataMapper::Resource
  # property :id,                Serial
  property :firstname,         String, required: true
  property :lastname,          String, required: true
  property :email,             String, required: true, length: 255, key: true
  property :password_hash,     BCryptHash, required: true
  property :cell_phone_number, String, required: true
  property :street_address,    String, required: true, length: 128
  property :apartment_number,  String, required: false
  property :city,              String, required: true, length: 128
  property :state,             String, required: true
  property :country,           String, required: true
  property :zip_code,          String, required: true
  property :is_walker,         Boolean, default: false
  property :is_activated,      Boolean, default: false
  property :is_admin,          Boolean, default: false
  property :created_at,        DateTime, required: true

  has n, :dogprofiles
  has n, :dogwalks

  has n, :installations

  has 1, :gmresponse

  has 1, :gcsimage
end
