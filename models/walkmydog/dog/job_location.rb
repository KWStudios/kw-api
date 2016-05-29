# The Location representing database class
class JobLocation
  include DataMapper::Resource
  property :id,                  Serial
  property :latitude,            Float
  property :longitude,           Float
  property :created_at,          DateTime
  property :updated_at,          DateTime

  belongs_to :dogwalk
end
