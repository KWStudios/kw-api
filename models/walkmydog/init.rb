# encoding: utf-8
db_file = open(File.expand_path('../../json/walk_db.json',
                                File.dirname(__FILE__)))
db_json = db_file.read
db = JSON.parse(db_json)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://#{db['username']}:"\
                                                  "#{db['password']}@"\
                                                  "#{db['hostname']}/"\
                                                  "#{db['database']}")

require_relative 'profile'
require_relative 'installation'

DataMapper.finalize
