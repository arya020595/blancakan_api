# frozen_string_literal: true

module V1
  module Event
    class EventForm < ApplicationForm
      attribute :title, :string
      attribute :description, :string
      attribute :start_date, :date
      attribute :start_time, :time
      attribute :end_date, :date
      attribute :end_time, :time
      attribute :location_type, :string
      attribute :location
      attribute :timezone, :string
      attribute :organizer_id, :string
      attribute :event_type_id, :string
      attribute :category_ids
      attribute :cover_image # File upload handled by CarrierWave
      attribute :status, :string
      attribute :is_paid, :boolean

      def initialize(params = {})
        super(params)
        @contract = ::V1::Event::EventContract.new
      end

      def valid?
        @validation_result = @contract.call(sanitized_attributes)
        @validation_result.success?
      end

      def errors
        return @errors if defined?(@errors)

        raise 'You must call `valid?` before accessing `errors`' unless @validation_result

        @errors = ActiveModel::Errors.new(self).tap do |am_errors|
          @validation_result.errors.to_h.each do |field, messages|
            Array(messages).each { |msg| am_errors.add(field, msg) }
          end
        end
      end

      # Sanitized and processed attributes
      def sanitized_attributes
        {
          title: strip_string(title),
          description: strip_string(description),
          start_date: parse_date(start_date),
          start_time: parse_time(start_time),
          end_date: parse_date(end_date),
          end_time: parse_time(end_time),
          location_type: strip_string(location_type),
          location: location,
          timezone: strip_string(timezone),
          organizer_id: organizer_id,
          event_type_id: event_type_id,
          category_ids: sanitize_array(category_ids),
          cover_image: cover_image, # File upload handled by CarrierWave
          is_paid: is_paid
        }.compact
      end

      # Keep backward compatibility
      alias attributes sanitized_attributes
    end
  end
end
