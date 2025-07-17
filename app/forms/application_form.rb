# frozen_string_literal: true

# Base class for all form objects in the application
# Provides common functionality and patterns for input validation
class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Common method to get sanitized attributes
  # Override in subclasses for specific sanitization logic
  def sanitized_attributes
    attributes.compact
  end

  # Alias for backward compatibility
  alias to_h sanitized_attributes

  protected

  # Helper method for stripping strings
  def strip_string(value)
    value&.strip
  end

  # Helper method for parsing datetime strings
  def parse_datetime(value)
    return value if value.is_a?(Time) || value.is_a?(DateTime)
    return nil if value.blank?

    Time.parse(value.to_s)
  rescue ArgumentError
    value # Return original value, let validation handle the error
  end

  # Helper method for parsing date strings
  def parse_date(value)
    return value if value.is_a?(Date) || value.is_a?(Time) || value.is_a?(DateTime)
    return nil if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    value # Return original value, let validation handle the error
  end

  # Helper method for parsing time strings
  def parse_time(value)
    return value if value.is_a?(Time) || value.is_a?(DateTime)
    return nil if value.blank?

    Time.parse(value.to_s)
  rescue ArgumentError
    value # Return original value, let validation handle the error
  end

  # Helper method for sanitizing URL inputs
  def sanitize_url(value)
    return nil if value.blank?

    url = strip_string(value)
    return nil if url.blank?

    # Basic URL format validation - return as-is for further validation
    url
  end

  # Helper method for sanitizing array inputs
  def sanitize_array(value)
    return [] if value.blank?

    Array(value).compact.reject(&:blank?).uniq
  end
end
