# The route for adding Braintree payment methods
class KWApi < Sinatra::Base
  post '/walkmydog/braintree/payment_methods/add/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    nonce = params[:nonce]
    if nonce.nil?
      halt 422, { 'Content-Type' => 'application/json' },
           missing_parameters_json
    end

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

    token = result.payment_method.token

    if !result.success? || token.nil?
      halt 500, { 'Content-Type' => 'application/json' },
           internal_server_error_json
    end

    payment_method = profile.paymentMethods.new
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
