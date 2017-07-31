# The main class for the TravisWebhook
class KWApi < Sinatra::Base
  set :token, ENV['TRAVIS_USER_TOKEN']

  # Use travis-ci.org as default host if no API_HOST env variable is present
  DEFAULT_API_HOST = 'https://api.travis-ci.org'
  API_HOST = ENV.fetch('API_HOST', DEFAULT_API_HOST)

  post '/travis/webhooks/versions/?' do
    begin
      json_payload = params.fetch('payload', '')
      signature = request.env['HTTP_SIGNATURE']

      pkey = OpenSSL::PKey::RSA.new(public_key)

      verified = pkey.verify(
        OpenSSL::Digest::SHA1.new,
        Base64.decode64(signature),
        json_payload
      )
      msg = nil
      if verified
        # Run add version
        number = json_payload['number']
        version = Version.first_or_create(name: "#{repo_slug.downcase}")
        version.version = number
        version.completed_at = Time.now
        version.save
        logger.info 'Authenticated successfully!'
        logger.info 'Welcome, TravisCI!'
        logger.info "Changing stuff on #{repo_slug} repo_slug"
        logger.info "Received valid payload for repository #{repo_slug}"
        # End Run add version

        status 200
        msg = {
          status: 200,
          error: 'verification succeeded'
        }
      else
        status 400
        msg = {
          status: 400,
          error: 'verification failed'
        }
      end
      JSON.generate(msg)
    rescue => e
      logger.info "exception=#{e.class} message=\"#{e.message}\""
      logger.debug e.backtrace.join("\n")

      status 500
      msg = {
        status: 500,
        error: 'exception encountered while verifying signature'
      }
      JSON.generate(msg)
    end
  end

  def public_key
    request = Typhoeus::Request.new(
      "#{API_HOST}/config",
      method: :get,
      headers: { Accept: 'application/json' }
    )
    request.run
    resp = request.response

    JSON.parse(resp.body)['config']['notifications']['webhook']['public_key']
  rescue
    ''
  end

  def repo_slug
    env['HTTP_TRAVIS_REPO_SLUG']
  end

  get '/plugins/:user/:repo/versions/newest/?' do
    version = Version.first_or_create(name: "#{params[:user].downcase}/"\
                                            "#{params[:repo].downcase}")
    if version.version.nil?
      'This api has not any data stored yet :/'
    else
      updater_file = open('https://raw.githubusercontent.com/'\
                          "#{params[:user].downcase}/#{params[:repo].downcase}"\
                          '/master/updater.json')
      updater_json = updater_file.read
      updater = JSON.parse(updater_json)
      send_file open("https://storage.googleapis.com/#{updater['BUCKET']}/"\
                  "travis/#{params[:repo].downcase}/#{version.version}/"\
                  "#{params[:repo].downcase}-#{updater['VERSION']}.jar"),
                filename: "#{params[:repo].downcase}-#{updater['VERSION']}.jar"
    end
  end
end
