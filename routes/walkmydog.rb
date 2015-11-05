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
        login_json_hash = { firstname: firstname, lastname: lastname, email: email,
                      is_activated: is_activated, status: 200 }
        login_json_string = JSON.generate(login_json_hash)

        content_type 'application/json'
        login_json_string
      else
        login_json_hash = { message: 'The given password is not correct for this account.', status: 1 }
        login_json_string = JSON.generate(login_json_hash)

        content_type 'application/json'
        login_json_string
      end
    else
      login_json_hash = { message: 'You have not registered this account yet.', status: 2}
      login_json_string = JSON.generate(login_json_hash)

      content_type 'application/json'
      login_json_string
    end
  end

  # Main method for new registrations
  post '/walkmydog/users/register/?' do
    firstname = params[:firstname]
    lastname = params[:lastname]
    email = params[:email]
    password = params[:password]

    if(!firstname.nil? and !lastname.nil? and !email.nil? and !password.nil?)

    else
      register_json_hash = { message: 'Not Extended', status: 510}
    end
  end
end
