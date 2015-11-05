# The main class for all easter eggs
class KWApi < Sinatra::Base

  get '/eastereggs/barney' do
    stream do |out|
      out << "It's gonna be legen -\n"
      sleep 2
      out << " (wait for it) \n"
      sleep 5
      out << "- dary!\n"
    end
  end
end
