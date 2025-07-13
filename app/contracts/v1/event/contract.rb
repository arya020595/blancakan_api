# frozen_string_literal: true

require 'dry/validation'

module V1
  module Event
    class Contract < Dry::Validation::Contract
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
        optional(:cover_image_url).filled(:string)
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
        ActiveSupport::TimeZone.all.map(&:name).include?(timezone)
      rescue StandardError
        false
      end
    end
  end
end
