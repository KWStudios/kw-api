# The Version representing database class
class Version
  include DataMapper::Resource
  def self.default_repository_name
    :default
  end
  property :id,           Serial
  property :name,         String, required: true
  property :version,      String
  property :completed_at, DateTime
end
