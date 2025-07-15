# frozen_string_literal: true

class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base
  ALGORITHM = 'HS256'
  # Token expiration time - configurable via environment variable
  # Set JWT_EXPIRY_HOURS in your environment (default: 24 hours)
  # Examples:
  # JWT_EXPIRY_HOURS=1    # 1 hour
  # JWT_EXPIRY_HOURS=24   # 24 hours (default)
  # JWT_EXPIRY_HOURS=168  # 7 days
  EXPIRY_HOURS = ENV.fetch('JWT_EXPIRY_HOURS', 24).to_i
  EXPIRY = EXPIRY_HOURS.hours.from_now.to_i

  def self.encode(payload, exp = EXPIRY)
    payload[:exp] = exp
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
