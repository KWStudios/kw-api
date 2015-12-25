# The Players representing database class
class Players
  include DataMapper::Resource
  def self.default_repository_name
    :mc
  end
  property :id,           Serial
  property :name,         String
  property :uuid,         Text, required: true
  property :server,       Text
  property :first_played, DateTime
  property :last_played,  DateTime
  property :is_online,    Boolean, default: false
  property :is_banned,    Boolean, default: false
end
