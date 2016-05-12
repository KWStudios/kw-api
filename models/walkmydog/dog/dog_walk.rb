# The DogWalk representing database class
class Dogwalk
  include DataMapper::Resource
  property :id,                  Serial
  property :scheduled_time,      DateTime, required: true
  property :timeframe_lower,     DateTime
  property :timeframe_upper,     DateTime
  property :type_of_job,         String, length: 255, required: true
  property :notes,               Text, required: false
  property :was_acknowledged,    Boolean, default: false
  property :has_started,         Boolean, default: false
  property :was_finished,        Boolean, default: false
  property :is_weekly,           Boolean, default: false
  property :created_at,          DateTime
  property :updated_at,          DateTime

  belongs_to :dogprofile
  belongs_to :profile, required: false
end
