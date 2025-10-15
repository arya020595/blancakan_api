require 'rails'
require 'time'

# HelperLogger provides logging methods with structured log entries for Rails applications.
#
# Example output:
# {
#   "timestamp": "2025-08-23T12:34:56Z",
#   "level": "WARN",
#   "class": "MyClass",
#   "message": "Something happened",
#   "extra": {"user_id": 123}
# }
#
# Usage:
# HelperLogger.warn("Something happened", klass: self.class.name, extra: {user_id: 123})
# HelperLogger.info("Process started")
# HelperLogger.error("Error occurred", extra: {error_code: 500})
module HelperLogger
  LOG_LEVELS = %i[debug info warn error fatal unknown].freeze

  def self.log(level, message, klass: nil, extra: {})
    raise ArgumentError, 'Invalid log level' unless LOG_LEVELS.include?(level)

    klass ||= caller_locations(1, 1)[0].label
    log_entry = {
      timestamp: Time.current.utc.iso8601,
      level: level.to_s.upcase,
      class: klass,
      message: message,
      extra: extra
    }
    Rails.logger.send(level, log_entry.to_json)
  end

  LOG_LEVELS.each do |level|
    define_singleton_method(level) do |message, klass: nil, extra: {}|
      log(level, message, klass: klass, extra: extra)
    end
  end
end
