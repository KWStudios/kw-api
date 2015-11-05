# The main class for all easter eggs
class KWApi < Sinatra::Base

  get '/eastereggs/barney' do
    stream do |out|
      out << "It's gonna be legen -\n"
      sleep 0.5
      out << " (wait for it) \n"
      sleep 1
      out << "- dary!\n"
    end
  end
end
