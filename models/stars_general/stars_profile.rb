# The Facebook profile representing database class
class Fbstarsprofile
  include DataMapper::Resource
  def self.default_repository_name
    :stars_general
  end
  property :id,           String, required: true, length: 128, key: true
  property :name,         String, length: 100
  property :first_name,   String
  property :last_name,    String
  property :link,         String, length: 255
  property :gender,       String
  property :locale,       String
  property :timezone,     Float
  property :updated_time, DateTime
  property :verified,     Boolean
  property :email,        String, length: 255
  property :created_at,   DateTime
  property :updated_at,   DateTime

  has 1, :starsvote

  has n, :starsgcsimages
end
