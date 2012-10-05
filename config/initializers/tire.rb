require 'yajl/json_gem'

Tire.configure do
  url ENV['SEARCHBOX_URL']
  logger STDOUT
end