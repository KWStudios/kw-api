# The DogWalk representing database class
class Dogwalk
  include DataMapper::Resource
  # property :id,                Serial
  property :scheduled_time,      DateTime, required: true
  property :type_of_job,         String, length: 255, required: true
  property :notes,               Text, required: false
  property :created_at,          DateTime
  property :updated_at,          DateTime

  belongs_to :dogprofile, key: true
end
