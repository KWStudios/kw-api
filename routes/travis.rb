# The main class for the TravisWebhook
class KWApi < Sinatra::Base
  set :token, ENV['TRAVIS_USER_TOKEN']

  post '/travis/webhooks/versions/?' do
    if !valid_request?
      puts "Invalid payload request for repository #{repo_slug}"
    else
      payload = JSON.parse(params[:payload])
      number = payload['number']
      version = Version.first_or_create(name: "#{repo_slug.downcase}")
      version.version = number
      version.completed_at = Time.now
      version.save
      puts 'Authenticated successfully!'
      puts 'Welcome, TravisCI!'
      puts "Changing stuff on #{repo_slug} repo_slug"
      puts "Received valid payload for repository #{repo_slug}"
    end
  end

  def valid_request?
    digest = Digest::SHA2.new.update("#{repo_slug}#{settings.token}")
    digest.to_s == authorization
  end

  def authorization
    env['HTTP_AUTHORIZATION']
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
                filename: "#{updater['VERSION']}.jar}"
    end
  end
end
