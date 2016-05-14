# The Walkmydog braintree payment representing database class
class PaymentMethod
  include DataMapper::Resource
  property :id,                Serial
  property :token,             String, required: true, length: 50
  property :created_at,        DateTime
  property :updated_at,        DateTime

  belongs_to :profile
end
