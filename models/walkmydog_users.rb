# The Walkmydog users representing database class
class Walkmydog_users
  include DataMapper::Resource
  property :id,           Serial
  property :firstname,    String, required: true
  property :lastname,     String, required: true
  property :email,        Text, required: true
  property :password,     Text, required: true
  property :is_activated, Boolean, default: false
end
