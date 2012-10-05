# Make Rails log to stdout: from https://github.com/ddollar/rails_log_stdout
logger = Logger.new(STDOUT)
logger.level = Logger.const_get(([ENV['LOG_LEVEL'].to_s.upcase, "INFO"] & %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]).compact.first)
Rails.logger = Rails.application.config.logger = logger

# Scrolls for log output
Scrolls.global_context(app: "gisted", env: ENV["RAILS_ENV"])
Scrolls.time_unit = "ms"

# Convenience log methods

require 'active_support/concern'

module EventLogger

  extend ActiveSupport::Concern

  module ClassMethods

    def log_context(*segments, &block)
      Scrolls.context(log_data_from(*segments), &block)
    end

    def log(*segments, &block)
      Scrolls.log(log_data_from(*segments), &block)
    end

    private

    def log_data_from(*segments)
      segments.inject({}) do |map, segment|
        map.merge!(segment.to_log)
      end
    end

  end

  def log(*segments, &block)
    self.class.log(*segments, &block)
  end
end

class Hash
  def to_log
    self
  end
end

class Object
  include EventLogger
end