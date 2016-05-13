# The route for getting Braintree client tokens
class KWApi < Sinatra::Base
  post '/walkmydog/braintree/client_token/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    Braintree::Configuration.environment = :sandbox
    Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT']
    Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC']
    Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE']

    if profile.braintree_id.nil?
      result = Braintree::Customer.create(
        first_name: profile.firstname,
        last_name: profile.lastname,
        email: profile.email,
        phone: profile.cell_phone_number
      )
      if result.success?
        profile.braintree_id = result.customer.id
        profile.save
      else
        p result.errors
      end
    end

    Braintree::ClientToken.generate(
      customer_id: profile.braintree_id
    )
  end
end
