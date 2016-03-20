# The Dog profile representing database class
class Dogprofile
  include DataMapper::Resource
  property :id,                  Serial
  property :pet_species,         String, required: true
  property :pet_name,            String, required: true
  property :pet_age,             String, required: true
  property :alarm_system_info,   Text, required: false
  property :pet_characteristics, Text, required: false
  property :created_at,          DateTime
  property :updated_at,          DateTime

  has n, :dogwalks

  belongs_to :profile
end
