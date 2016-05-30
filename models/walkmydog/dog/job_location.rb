# The Location representing database class
class JobLocation
  include DataMapper::Resource
  property :id,                  Serial
  property :latitude,            Float, precision: 53
  property :longitude,           Float, precision: 53
  property :created_at,          DateTime
  property :updated_at,          DateTime

  belongs_to :dogwalk
end
