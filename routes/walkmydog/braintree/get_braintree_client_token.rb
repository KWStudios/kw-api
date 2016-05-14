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
        halt 500, { 'Content-Type' => 'application/json' },
             internal_server_error_json
      end
    end

    token = Braintree::ClientToken.generate(
      customer_id: profile.braintree_id
    )

    token_hash = { client_token: token }
    token_string = JSON.generate(token_hash)

    content_type 'application/json'
    token_string
  end
end
