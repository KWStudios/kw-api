# The Stars votes representing class
class Starsimagevote
  include DataMapper::Resource
  def self.default_repository_name
    :stars_general
  end
  property :id,                Serial
  property :created_at,        DateTime
  property :updated_at,        DateTime

  has n, :starsupvotes
  has n, :starsdownvotes
  has n, :starsgreatvotes

  belongs_to :starsgcsimage
end

# The Stars votes representing class
class Starsvote
  include DataMapper::Resource
  def self.default_repository_name
    :stars_general
  end
  property :id,                Serial
  property :created_at,        DateTime
  property :updated_at,        DateTime

  has n, :starsupvotes
  has n, :starsdownvotes
  has n, :starsgreatvotes

  belongs_to :fbstarsprofile
end

# The voting account
class Starsupvote
  include DataMapper::Resource
  def self.default_repository_name
    :stars_general
  end
  property :id,           Serial
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :starsgcsimage
  belongs_to :starsvote
end

# The voting account
class Starsdownvote
  include DataMapper::Resource
  def self.default_repository_name
    :stars_general
  end
  property :id,           Serial
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :starsgcsimage
  belongs_to :starsvote
end

# The voting account
class Starsgreatvote
  include DataMapper::Resource
  def self.default_repository_name
    :stars_general
  end
  property :id,           Serial
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :starsgcsimage
  belongs_to :starsvote
end
