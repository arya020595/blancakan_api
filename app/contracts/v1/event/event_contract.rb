# frozen_string_literal: true

require 'dry/validation'

module V1
  module Event
    class EventContract < Dry::Validation::Contract
      params do
        required(:title).filled(:string)
        required(:description).filled(:string)
        required(:start_date).filled(:date)
        required(:start_time).filled(:time)
        required(:end_date).filled(:date)
        required(:end_time).filled(:time)
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

      rule(:start_date, :end_date, :start_time, :end_time) do
        if values[:start_date] && values[:end_date] && values[:start_time] && values[:end_time]
          start_datetime = combine_date_time(values[:start_date], values[:start_time])
          end_datetime = combine_date_time(values[:end_date], values[:end_time])

          key(:end_date).failure('must be after start date and time') if start_datetime >= end_datetime
          key(:start_date).failure('cannot be in the past') if start_datetime < Time.current
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

      def combine_date_time(date, time)
        DateTime.new(date.year, date.month, date.day, time.hour, time.min)
      end

      def valid_timezone?(timezone)
        tz = timezone.to_s.strip
        return false if tz.empty?

        # Case-insensitive match against Rails time zone names
        ActiveSupport::TimeZone.all.any? { |zone| zone.name.casecmp?(tz) }
      rescue StandardError
        false
      end
    end
  end
end
