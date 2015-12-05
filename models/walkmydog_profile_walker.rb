# The Walkmydog users representing database class
class WalkmydogProfileWalker
  include DataMapper::Resource
  property :id,                Serial
  property :firstname,         Text, required: true
  property :lastname,          Text, required: true
  property :email,             Text, required: true
  property :password,          Text, required: true
  property :cell_phone_number, Text, required: true
  property :street_adress,     Text, required: true
  property :apartment_number,  Integer, required: false
  property :city,              Text, required: true
  property :zip_code,          Integer, required: true
  property :is_activated,      Boolean, default: false
end
