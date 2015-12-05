require 'data_mapper'
require 'json'

db_file = open(File.expand_path('../json/db.json', File.dirname(__FILE__)))
db_json = db_file.read
db = JSON.parse(db_json)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://#{db['username']}:"\
                                                  "#{db['password']}@"\
                                                  "#{db['hostname']}/"\
                                                  "#{db['database']}")

# require_relative 'version'
# require_relative 'players'
require_relative 'walkmydog_profile_walker'

DataMapper.finalize
