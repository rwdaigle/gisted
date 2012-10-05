# Make Rails log to stdout: from https://github.com/ddollar/rails_log_stdout
logger = Logger.new(STDOUT)
logger.level = Logger.const_get(([ENV['LOG_LEVEL'].to_s.upcase, "INFO"] & %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]).compact.first)
Rails.logger = Rails.application.config.logger = logger

Scrolls.global_context(app: "gisted", env: ENV["RAILS_ENV"])
Scrolls.time_unit = "ms"