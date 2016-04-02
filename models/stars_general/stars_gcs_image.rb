# The Stars gcs image representing class
class Starsgcsimage
  include DataMapper::Resource
  property :id,                Serial
  property :gcs_key,           String, required: true, length: 255
  property :gcs_bucket,        String, required: true, length: 255
  property :content_type,      String, required: true, length: 255
  property :category,          String, length: 255
  property :created_at,        DateTime
  property :updated_at,        DateTime

  belongs_to :fbstarsprofile, required: false
end
