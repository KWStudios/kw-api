# The route for getting Braintree client tokens
class KWApi < Sinatra::Base
  post '/walkmydog/braintree/payment_methods/add/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    nonce = params[:nonce]
    if nonce.nil?
      halt 422, { 'Content-Type' => 'application/json' },
           missing_parameters_json
    end

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

    result = Braintree::PaymentMethod.create(
      customer_id: profile.braintree_id,
      payment_method_nonce: nonce
    )

    puts "Result: #{result.payment_method.token}"

    token = result.payment_method.token

    if !result.success? || token.nil?
      halt 500, { 'Content-Type' => 'application/json' },
           internal_server_error_json
    end

    payment_method = profile.paymentmethods.new
    payment_method.token = token

    profile.save

    unless profile.saved?
      halt 500, { 'Content-Type' => 'application/json' },
           internal_server_error_json
    end

    content_type 'application/json'
    get_payment_method_json_string(payment_method)
  end
end
