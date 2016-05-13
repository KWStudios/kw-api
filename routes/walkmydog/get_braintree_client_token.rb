# The route for getting Braintree client tokens
class KWApi < Sinatra::Base
  post '/walkmydog/braintree/client_token/?' do
    verify_login(params[:payload])

    profile = Profile.get(JSON.parse(params[:payload])['email'])

    Braintree::ClientToken.generate(
      customer_id: a_customer_id
    )
  end
end
