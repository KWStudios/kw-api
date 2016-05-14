# The route for getting Braintree payment methods
class KWApi < Sinatra::Base
  post '/walkmydog/braintree/payment_methods/all/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    payment_methods = profile.paymentMethods

    payment_methods_json_hash = []
    payment_methods.each do |payment_method|
      payment_methods_json_hash << get_payment_method_json_hash(payment_method)
    end

    status 200
    payment_methods_json_string = JSON.generate(payment_methods_json_hash)

    content_type 'application/json'
    payment_methods_json_string
  end
end
