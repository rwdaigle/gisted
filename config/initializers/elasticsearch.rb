require 'yajl/json_gem'

ENV['ELASTICSEARCH_URL'] = ENV['BONSAI_URL'] || ENV['SEARCHBOX_URL']

# Optional, but recommended: use a single index per application per environment
app_name = Rails.application.class.parent_name.underscore.dasherize
ELASTICSEARCH_INDEX_NAME = "#{app_name}-#{Rails.env}"

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