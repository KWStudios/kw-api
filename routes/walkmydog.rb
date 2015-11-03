# The main class for all the WalkMyDog routes
class KWApi < Sinatra::Base

  # The post method to check a users password
  post '/walkmydog/users/checklogin/?' do
    user = Walkmydog_users.first(name: params[:email])

    if !user.nil?
      firstname = user.firstname
      lastname = user.lastname
      passwordSaved = user.password
      is_activated = user.is_activated

      email = params[:email]
      passwordGiven = params[:password]

      if passwordGiven == passwordSaved
        json_hash = { firstname: firstname, lastname: lastname, email: email,
                      is_activated: is_activated }
        json_string = JSON.generate(json_hash)

        content_type 'application/json'
        json_string
      else
        json_hash = { message: 'The given password is not correct for this account.', status: 1 }
        json_string = JSON.generate(json_hash)

        content_type 'application/json'
        json_string
      end
    else
      json_hash = { message: 'You have not registered this account yet.', status: 2}
      json_string = JSON.generate(json_hash)

      content_type 'application/json'
      json_string
    end
  end
end
