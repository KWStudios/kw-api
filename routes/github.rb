# The main class for the Github webhook
# (Automatic project update on push to repository)
class KWApi < Sinatra::Base
  set :token, ENV['GITHUB_SECRET']

  post '/github/webhooks/kw-api/update' do
    request.body.rewind
    payload_body = request.body.read
    verify_signature(payload_body)
    push = JSON.parse(params[:payload])
    puts "I got some JSON: #{push.inspect}"
    `git pull`
    `bundle install`
    `bundle exec passenger-config restart-app /var/www`
  end

  def verify_signature(payload_body)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
                                                  settings.token, payload_body)
    return halt 500, "Signatures didn't match!" unless
    Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end
end
