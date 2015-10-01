# The main class for the Github webhook
# (Automatic project update on push to repository)
class KWApi < Sinatra::Base
  set :github_secret_token, ENV['GITHUB_SECRET']

  post '/github/webhooks/kw-api/update' do
    request.body.rewind
    payload_body = request.body.read
    verify_signature(payload_body)
    puts 'I got some JSON!'
    `git pull`
    `bundle install`
    `bundle exec passenger-config restart-app /var/www`
  end

  def verify_signature(payload_body)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
                                                  settings.github_secret_token,
                                                  payload_body)
    return halt 500, "Signatures didn't match!" unless
    Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end
end
