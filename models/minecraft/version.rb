# The Version representing database class
class Version
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, required: true
  property :version,      String
  property :completed_at, DateTime
end
