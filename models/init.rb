require 'data_mapper'
require 'json'

db_file = open('../json/db.json')
db_json = db_file.read
db = JSON.parse(db_json)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://#{db['username']}:"\
                                                  "#{db['password']}@"\
                                                  "#{db['hostname']}/"\
                                                  "#{db['database']}")

require_relative 'version'

DataMapper.finalize
