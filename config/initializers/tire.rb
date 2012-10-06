require 'yajl/json_gem'

Tire.configure do
  url ENV['BASE_BONSAI_URL']
  BONSAI_INDEX_NAME = ENV['BONSAI_INDEX_URL'][/[^\/]+$/]
  # url ENV['SEARCHBOX_URL']
  logger STDOUT, :level => ENV['LOG_LEVEL']
end

module Tire
  class Logger
    def log_request(endpoint, params=nil, curl='')
      Scrolls.log(ns: 'tire', fn: endpoint, params: params, level: level)
    end

    def log_response(status, took=nil, json='')
      Scrolls.log(ns: 'tire', fn: 'response', status: status, elapsed: took, level: level)
    end
  end
end