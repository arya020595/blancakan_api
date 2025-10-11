# frozen_string_literal: true

require 'dry/validation'

module V1
  module Event
    class EventContract < Dry::Validation::Contract
      INDONESIA_TIMEZONES = ['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'].freeze

      params do
        required(:title).filled(:string)
        required(:description).filled(:string)
        required(:starts_at_local).filled(:date_time)  # Combined datetime field
        required(:ends_at_local).filled(:date_time)    # Combined datetime field
        required(:location_type).filled(:string)
        required(:timezone).filled(:string)
        required(:event_type_id).filled
        required(:organizer_id).filled
        optional(:cover_image)
        optional(:status).filled(:string)
        optional(:location).filled(:hash)
        optional(:is_paid).filled(:bool)
        optional(:category_ids).filled(:array)
      end

      # Business rules validation
      rule(:title) do
        key.failure('must be at least 3 characters') if value.length < 3
        key.failure('must be at most 255 characters') if value.length > 255
      end

      rule(:description) do
        key.failure('must be at least 10 characters') if value.length < 10
        key.failure('must be at most 5000 characters') if value.length > 5000
      end

      rule(:location_type) do
        key.failure('must be online, offline, or hybrid') unless %w[online offline hybrid].include?(value)
      end

      rule(:timezone) do
        key.failure('is not a valid timezone') unless valid_timezone?(value)
      end

      rule(:status) do
        if key? && value
          valid_statuses = %w[draft published cancelled rejected]
          key.failure('must be one of: draft, published, cancelled, rejected') unless valid_statuses.include?(value)
        end
      end

      rule(:cover_image) do
        if key? && value
          # Allow string URLs
          if value.is_a?(String)
            # Basic URL validation if it's a string
            unless value.match?(/\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/) || value.blank?
              key.failure('must be a valid URL if provided as string')
            end
          # Allow file uploads (ActionDispatch::Http::UploadedFile)
          elsif defined?(ActionDispatch::Http::UploadedFile) && value.is_a?(ActionDispatch::Http::UploadedFile)
            # Validate file type
            allowed_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
            unless allowed_types.include?(value.content_type)
              key.failure('must be a valid image file (JPEG, PNG, GIF, WebP)')
            end

            # Validate file size (5MB limit)
            max_size = 5.megabytes
            key.failure('file size must be less than 5MB') if value.size > max_size
          # Allow other file-like objects (for testing or other upload methods)
          elsif value.respond_to?(:read) && value.respond_to?(:original_filename)
            # This covers other file upload scenarios
            # File validation would happen at the CarrierWave level
          else
            key.failure('must be either a valid URL string or an uploaded file')
          end
        end
      end

      rule(:starts_at_local, :ends_at_local, :timezone) do
        if values[:starts_at_local] && values[:ends_at_local] && values[:timezone]
          # Convert to UTC for comparison (timezone-safe)
          tz = ActiveSupport::TimeZone[values[:timezone]] || ActiveSupport::TimeZone['Asia/Jakarta']
          starts_utc = values[:starts_at_local].in_time_zone(tz).utc
          ends_utc = values[:ends_at_local].in_time_zone(tz).utc

          key(:ends_at_local).failure('must be after start datetime') if starts_utc >= ends_utc
          key(:starts_at_local).failure('cannot be in the past') if starts_utc < Time.current.utc
        end
      end

      rule(:location, :location_type) do
        if values[:location_type] == 'offline' && (!values[:location] || values[:location].empty?)
          key(:location).failure('is required for offline events')
        end
      end

      rule(:organizer_id) do
        key.failure('organizer does not exist') if key? && value.present? && !::Organizer.where(id: value).exists?
      end

      rule(:event_type_id) do
        key.failure('event type does not exist') if key? && value.present? && !::EventType.where(id: value).exists?
      end

      rule(:category_ids) do
        if key? && value && value.is_a?(Array)
          key.failure('must have at least one category') if value.empty?
          key.failure('cannot have more than 5 categories') if value.length > 5
        end
      end

      private

      def valid_timezone?(timezone)
        tz = timezone.to_s.strip
        return false if tz.empty?

        # Only allow a small set of Indonesian timezones for now
        INDONESIA_TIMEZONES.any? { |allowed| allowed.casecmp?(tz) }
      rescue StandardError
        false
      end
    end
  end
end
